class VenuesController < ApplicationController
  @@auth = Authentication.get_keys
  
  @@watch_no = "Stop watching this venue?"
  @@watch_yes = "Watch this venue?"
  @@no_photo = ['https://foursquare.com/img/blank_girl.png','https://foursquare.com/img/blank_girl.png']
  
  def random
#    if session[:random_venues].nil? || session[:random_venues].empty?
#      @seed = rand(9999999)
#      foursquare_obj = JSON.parse(Authentication.req('foursquare').request(
#      :get, "https://api.foursquare.com/v2/venues/#{@seed}",
#      :client_id => @@auth[:key],
#      :client_secret => @@auth[:secret],
#      :oauth_token => session[:oauth]['foursquare']))
#      
#      if foursquare_obj['response']
#        @foursquare_venue = foursquare_obj['response']['venue']
#        @lat = @foursquare_venue['location']['lat']
#        @lng = @foursquare_venue['location']['lng']
#        
#        foursquare_obj = JSON.parse(Authentication.req('foursquare').request(
#        :get, "https://api.foursquare.com/v2/venues/trending?ll=#{@lat},#{@lng}&radius=100000",
#        :client_id => @@auth[:key],
#        :client_secret => @@auth[:secret]))
#        
#        @foursquare_trending_venues = foursquare_obj['response']['venues']
#        session[:random_venues] = get_trending_venues
#      end
#    else
#      @venue = session[:random_venues].pop
#    end
  end
  
  def watch
    @venue = current_user.favorites.find_or_initialize_by_venue_id(params[:id])
    
    @watched = @venue.watched ? false : true
    @venue.update_attributes({:watched => @watched, :venuetype => 1})
    
    respond_to do |format|
      format.html {render :layout => false}
      format.json  { render :json => @venue }
    end
  end
  
  def add
    @venue = current_user.favorites.where("venue_id = ? AND venuetype = ?", params[:id], 1).first
    
    if @venue.nil?
      attr = {
      :user_id => current_user.id,
      :venue_id => params[:id],
      :venuetype => 1}
      
      @venue = current_user.favorites.create(attr)
    end
    
    respond_to do |format|
      format.html {render :layout => false}
      format.json  { render :json => @venue }
    end

  end
  
  def popular
    @popular_venues = Venue.limit(10).order("created_at DESC").where("people_count >= ?", 10).all
    
    respond_to do |format|
      format.html {render :layout => false}
      format.json  { render :json => @popular_venues }
    end
  end
  
  def people
  
    @venue = Venue.includes(:candies).find(params[:id])
    @user_candies = current_user.recommendations.where("recommended = ?", true).map{|c| c.candy_id.to_i }
    
    @limit_reached = current_user.jump_limit > 0 ? false : true
    
    @limit = 20
    @offset = params[:offset].to_i * @limit
    
    # Auto update candies
    @venue_last_update = @venue.created_at.strftime("%Y-%m-%d %H:%M:%S").to_time.to_i
    @now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @time_now = @now.to_time.to_i
    @diff = (@time_now - @venue_last_update) / 60
    
    
    if !@limit_reached && (@diff >= 30 || params[:refresh].to_i == 1 || @venue.candies.where("flag_status = 0").empty?)

      authentication = Authentication.where(:provider => 'foursquare', :user_id => current_user.id).first

      foursquare_obj = JSON.parse(Authentication.req('foursquare').request(
      :get, "https://api.foursquare.com/v2/multi?requests=/venues/#{@venue.foursquare_id},/venues/#{@venue.foursquare_id}/herenow",
      :client_id => @@auth[:key],
      :client_secret => @@auth[:secret],
      :oauth_token => authentication.access_token))
      
      candies = foursquare_obj['response']['responses'][1]['response']['hereNow']['items']
      
      candies.each do |candy|
        # Only get female users
        if candy['user']['gender'] == 'female' && !@@no_photo.include?(candy['user']['photo'])
          attr = {:pid => candy['user']['id'], :data => candy['user'], :venue_id => params[:id], :created_at => Time.at(candy['createdAt'])}
          
          p = Candy.find_or_initialize_by_pid(candy['user']['id'])
          new_candy = p.id.nil? ? true : false
          
          # Send candy notification to users who has this candy in portfolio
          if current_user.notify_candy && !new_candy && p.is_candy
          
            prev_time = p.created_at.to_i
            new_time = candy['createdAt']
            if new_time >= prev_time
              rand_id = rand(Candy.count)
              # Check candy's scouts
              p.created_at = Time.at(candy['createdAt'])
              p.users.where("recommended = true AND user_id != ?",current_user.id).each do |u|
                UserMailer.notify_mail(u.email, p, rand_id, @venue).deliver
              end
            end
          end
          
          p.update_attributes(attr)
          p.save
          
#          CandiesVenue.delete_all(:candy_id => p.id) if !new_candy
#          CandiesVenue.create({:candy_id => p.id, :venue_id => @venue.id, :created_at => Time.at(candy['createdAt'])})

        end
      end

      @candies = @venue.candies.limit(@limit).order("created_at DESC").where("flag_status = ?", 0)
      
      foursquare_venue = foursquare_obj['response']['responses'][0]['response']['venue']
      
      @venue.people_count = @venue.candies.where("flag_status = 0").count
      @venue.candy_count = @venue.candies.where("is_candy = true").count

      @venue.name = foursquare_venue['name']
      @venue.lat = foursquare_venue['location']['lat']
      @venue.lng = foursquare_venue['location']['lng']
      @venue.created_at = @now
      @venue.save
      
    else
      @candies = @venue.candies.limit(@limit).offset(@offset).order("created_at DESC").where("flag_status = ?", 0)
    
    end
    
    respond_to do |format|
      format.html {render :layout => false}# index.html.erb
      format.json  { render :json => @candies }
    end
    
  end
  
  def history
  
    user = User.find(params[:id])
    @user_venues = Favorite.find_by_sql("SELECT venues.*, favorites.venuetype, favorites.watched FROM venues
  INNER JOIN favorites ON favorites.venue_id = venues.id AND favorites.user_id = #{current_user.id} AND favorites.venuetype = 1 ORDER BY venues.name asc")
    
    respond_to do |format|
      format.html {render 'history', :layout => false}
      format.json  { render :json => @user_venues }
    end
  end
  
  def trending
    if params[:lat] == 0
      session[:trending] = Venue.where("people_count > 5").order("RANDOM()").limit(5).map{|v| v.id}
    end
    
    @limit_reached = current_user.jump_limit > 0 ? false : true
    
    lat = (params[:lat] and params[:lat] != '0') ? params[:lat] : 1.3047282647
    lng = (params[:lng] and params[:lng]!= '0') ? params[:lng] : 103.8318729401
    
    #@trending_venues = current_user.favorites.where("venuetype = ?", @trending_value).order("updated_at DESC").limit(5)

    if !@limit_reached and (params[:refresh].to_i == 1 || session[:trending].nil?)

      authentication = Authentication.where(:provider => 'foursquare', :user_id => current_user.id).first

      # Clear all user's trending venues
      #UsersVenue.delete_all(:user_id => current_user.id, :venue_type => 'trending')
      #UsersVenue.delete_all(["user_id = ? AND venuetype = ?", current_user.id, @trending_value])
      #current_user.favorites.where("venuetype = ?",@trending_value).delete_all
      #current_user.favorites.where("venuetype = ?", @trending_value).delete_all
      session[:trending] = []
      
      @foursquare_venues = JSON.parse(Authentication.req('foursquare').request(
      :get, "https://api.foursquare.com/v2/venues/trending",
      :ll => "#{lat}, #{lng}",
      :radius => 3000,
      :client_id => @@auth[:key],
      :client_secret => @@auth[:secret],
      :oauth_token => authentication.access_token))
      #@venues = auth
      
      @foursquare_trending_venues = @foursquare_venues['response']['venues']
      
      # Get venue groups
      session[:trending] = get_trending_venues
    end
        
    respond_to do |format|
      format.html {render 'trending', :layout => false}
      format.json  { render :json => @foursquare_trending_venues }
    end
  end
  
  def search
    authenticate_user!
    refresh_oauth
    
    session[:venue_back] = 'venues'
    @trending = current_user.favorites.where("venuetype = ?", 2).first
    
    respond_to do |format|
      format.html
    end

  end
  
  def candies
    authenticate_user!
    refresh_oauth
    
    @locked = false
    @watch_no = @@watch_no
    @watch_yes = @@watch_yes
    
    @rand_id = rand(Candy.count)
    
    if params[:id] == 'random'
      
      @limit_reached = current_user.jump_limit > 0 ? false : true
      
      render :action => 'limit_reached' and return if @limit_reached
      
      if session[:random_venues].nil? || session[:random_venues].empty?
      
        @venue = nil
        @seed = rand(8999999)+1000000
        
        freq = Authentication.req('foursquare').request(
        :get, "https://api.foursquare.com/v2/venues/#{@seed}",
        :client_id => @@auth[:key],
        :client_secret => @@auth[:secret],
        :oauth_token => session[:oauth]['foursquare'])
        
        foursquare_obj = freq && freq.status == 200 ? JSON.parse(freq) : nil
        
        if foursquare_obj
          @foursquare_venue = foursquare_obj['response']['venue']
          @lat = @foursquare_venue['location']['lat']
          @lng = @foursquare_venue['location']['lng']
          
          trendreq = Authentication.req('foursquare').request(
          :get, "https://api.foursquare.com/v2/venues/trending?ll=#{@lat},#{@lng}&radius=50000&limit=15",
          :client_id => @@auth[:key],
          :client_secret => @@auth[:secret])
          
          foursquare_obj = trendreq && trendreq.status == 200 ? JSON.parse(trendreq) : nil
          
          if foursquare_obj && foursquare_obj['response']
            @foursquare_trending_venues = foursquare_obj['response']['venues']
            
            result = get_trending_venues
            
            if !result.empty?
              session[:random_venues] = result
              @venue = Venue.find(session[:random_venues].pop)
            end
          
          end
          
        end
        # Randomly pick a venue if no foursquare results
        @venue = Venue.where("people_count >= 5").order("RANDOM()").limit(1).first if @venue.nil?
      else
        @venue = Venue.find(session[:random_venues].pop)
      end
      
      current_user.jump_limit -= 1
      current_user.save
      
    else
      # Display normal venue
      @venue = Venue.find(params[:id])
    end
    
    # Check if venue is locked
    if @venue.locked > 0
      @user_score = current_user.get_score
      @score_needed = @venue.locked - @user_score
      @locked = @venue.locked > @user_score ? true : false 
    end

    @candy_count = @venue.candies.where("is_candy = true").count
    
    @user_venues = {}
    @user_venues = current_user.venues.where("venuetype = ?", 1).map{|v| v.id}
    @favorite = @venue.favorites.find_by_user_id(current_user.id)

    session[:candies_offset] = params[:offset]
    
    # Get top candy of venue
    @queen = @venue.candies.where("is_candy = true").order("score DESC").first
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @venue }
      format.json { render :json => @venue }
    end

  end
  
  # GET /venues
  # GET /venues.xml
  def index
    authenticate_admin!
    @venues = Venue.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @venues }
    end
  end

  # GET /venues/1
  # GET /venues/1.xml
  def show
    authenticate_admin!
    @venue = Venue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/new
  # GET /venues/new.xml
  def new
    @venue = Venue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    authenticate_admin!
    @venue = Venue.find(params[:id])
  end

  # POST /venues
  # POST /venues.xml
  def create
    @venue = Venue.new(params[:venue])

    respond_to do |format|
      if @venue.save
        format.html { redirect_to(@venue, :notice => 'Venue was successfully created.') }
        format.xml  { render :xml => @venue, :status => :created, :location => @venue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /venues/1
  # PUT /venues/1.xml
  def update
    @venue = Venue.find(params[:id])

    respond_to do |format|
      if @venue.update_attributes(params[:venue])
        format.html { redirect_to(@venue, :notice => 'Venue was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.xml
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to(venues_url) }
      format.xml  { head :ok }
    end
  end
  
  private
    def watch_message(type)
      return type ? "Stop watching this venue?" : "Watch this venue?"
    end
    
    def get_trending_venues
    
      list = []
      @foursquare_trending_venues.each do |item|
        # Only get venue with at least 2 person
        if item['hereNow']['count'] > 1
          
          venue = Venue.find_or_initialize_by_foursquare_id(item['id'])
          
          lat = item['location']['lat']
          lng = item['location']['lng']
          venue.foursquare_id = item['id']
          venue.location = item['location']
          venue.name = item['name']
          venue.lat = lat
          venue.lng = lng
          
          venue.save
          
          list << venue.id
        end
      end
      return list
    end
    
end
