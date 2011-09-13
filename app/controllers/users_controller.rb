class UsersController < ApplicationController
  
#  def cron
#    @scouts = []
#    
#    User.all.each do |u|
#    
#      today = Time.now.to_date
#      candies = u.candies.where("is_candy = true AND recommended = true AND DATE(recommendations.created_at) = ? AND recommendations.user_id != ?",today, u.id).limit(8)
#      
#      
#      if !candies.empty?
#        candies.fill(nil, candies.size..7)
#        @list = []
#        for i in 0...3
#          p = candies.slice!(0..3)
#          if !p.at(0).nil?
#            #col = "<tr></td>"+p.join("</td><td>")+"</td></tr>"
#            @list << p
#          end
#        end
#        
#        rand_id = rand(Candy.count)
#        @candies = Candy.find_by_sql(
#        "SELECT * FROM candies WHERE id >= #{rand_id} AND is_candy = true LIMIT 3")
#        
#        UserMailer.daily_mail(u, @list, @candies).deliver
#        @scouts << u.email
#      end
#    end
#    
#    respond_to do |format|
#      format.json  { render :json => @scouts}
#    end
#    
#  end
  
  def candies_list
    @limit = 20
    @max = get_max_candy
    @offset = params[:offset].to_i * @limit
    #@candies = []

#    if current_user.id != @scout.id
#
#      @sql = @user_candies_list.map{|p| " AND candies.id != #{p}"}.join
#      @candies = @scout.candies.where("rejected = ? AND is_candy = ? AND recommended = ?#{@sql}",false, true, true).offset(@offset).limit(@limit).order("updated_at DESC")
#    end
    
    @candies = current_user.candies.includes(:venue,:photos,:users).limit(@limit).where("recommended = ?", true).offset(@offset).order("updated_at DESC, score DESC")

    
    respond_to do |format|
      format.html {render :layout => false} # show.html.erb
      format.json  { render :json => @candies}
    end
    
  end
  
  # User's portfolio
  def candies
    
    authenticate_user!
    
    # Offset page = 0 if coming from 'My Portfolio'
    session[:candies_offset] = 0 if (session[:candies_offset].nil? || params[:offset])

    @limit = 20
    @max = get_max_candy
    session[:venue_candies_back] = 'portfolio'
    @candy_status_list = []

    @title = "My Portfolio"
    
    # Eg. User's score must be >= 70% of scout's score
    #@score = 100
    
    #@user_candies_list = current_user.candies.where("recommended = ?", true).map{|c| c.id}
    @candy_status_list = Candy.candy_status_list
    #@candies = @scout.candies.where("recommended = ?", true).order("updated_at DESC")
    @candies = current_user.candies.where("recommended = ?", true).order("updated_at DESC")
    
    @candies.each do |candy|
      #@candy_status_list[candy.candy_status] << 1
      @candy_status_list.each do |status|
        status[:count] += 1 if status[:name] == candy.candy_status
      end
    end
    
    session[:venue_back] = 'portfolio'
  
      
    session[:venue_back_scout] = current_user.id
    
  end
  
  def leaderboard
    #@scouts = CandiesUser.group("user_id").select("user_id").all
    authenticate_user!
    
    # Reset page offset
    session[:candies_offset] = 0
    
    @scout_list = {}
    @scouts = {}
#    Candy.where("is_candy = ?", true).all.map{|c|
#      c.users.each do |u|
#        @scouts[u.id] = {
#        :photo => u.authentications.select("data").where("provider = ?", 'foursquare').first, 
#        :score => User.score(u), 
#        :id => u[:id]} if !@scouts.has_key?(u[:id])
#      end
#    }
    
    User.all.each do |u|
      score = u.candies.where("is_candy = ?", true).count#User.score(u)
      if score > 0
        @scout_list[u.id] = score
        @scouts[u.id] = {
        :score => score, 
        :id => u[:id]}
      end
    end
    
    @scout_list = @scout_list.sort {|a,b| b[1]<=>a[1]}
    
    rank = 1;
    @scout_list.each do |key, scout|
      @user_rank = rank if current_user.id == key
      rank += 1
    end

  end
  
  def add_candy
    #candy = current_user.candies.find_by_id(params[:id])
    #candy = Candy.find(818)
    session[:user_candies_list] = nil
    
    @recommendation = current_user.recommendations.find_by_candy_id(params[:id])
    
    if @recommendation.nil? || !@recommendation.recommended
      #CandiesUser.create({:candy_id => params[:id], :user_id => current_user.id})
      @candy = Candy.find(params[:id])
      
      @popularity = @candy.users.where("recommended = true").count
      
      is_candy = @candy.is_candy
      
      is_candy = true if current_user.verified

      attr = {:score => @popularity + 1, :venue_id => params[:venue_id], :is_candy => is_candy}
      
      # Save photos with paperclip
      candy_current_photo = @candy.data['photo'].gsub('userpix_thumbs', 'userpix')
      attr[:photos_attributes] = {@candy.photos.count => {:photo_remote_url => candy_current_photo}} if @candy.photos.empty?

      @candy.update_attributes(attr);
      
      candy_keys = Candy.candy_status_list
      
      case @candy.score
        when 1 then 
        @message = @candy.is_candy ? "Thank you for your support!" : "You discovered a new candy!"
        @caption = @candy.is_candy ? 
        "" :
        "She's now pending for approval :)"
        @candy_status = candy_keys[1][:name]
#        when 2 then 
#        @message = "You've got a <strong>#{candy_keys[1][:name]}</strong>!"
#        @candy_status = candy_keys[1][:name]
#        when 3..4 then 
#        @message = "You've got a <strong>#{candy_keys[2][:name]}</strong>!"
#        @candy_status = candy_keys[2][:name]
#        when 5..6 then 
#        @message = "You've got a <strong>#{candy_keys[3][:name]}</strong>!"
#        @candy_status = candy_keys[3][:name]
#        when 7..8 then 
#        @message = "You've got a <strong>#{candy_keys[4][:name]}</strong>!"
#        @candy_status = candy_keys[4][:name]
#        when 9..10 then @message = "You've got a <strong>#{candy_keys[5][:name]}</strong>!"
#        @candy_status = candy_keys[5][:name]
        else 
        @message = "Thank you for your support!"
        @candy_status = candy_keys[6][:name]
      end
      
      person = @candy.score - 1 > 1 ? 'scouts' : 'scout'
      @caption = "<div id='recommendations'>#{@candy.score-1} other #{person} also recommended this person!</div>" if @candy.score > 1
      
      #Send email notification
      UserMailer.spot_mail(@candy, current_user).deliver if @@send_email && (@candy.users.empty? && !@candy.is_candy)
      
      @added = true
      @candy.candy_status = @candy_status
      
#      # Send recommended email notification
#      if @@send_email && @recommendation.nil?
#        if @candy.is_candy && !@candy.users.empty?
#          rand_id = rand(Candy.count)
#          @candy.users.where("recommended = ?", true).each do |u|
#            UserMailer.recommended_mail(@candy, u.email, rand_id).deliver
#          end
#        end
#      end
      
      @recommendation = @candy.recommendations.find_or_initialize_by_user_id(current_user.id)
      @recommendation.recommended = true
      @recommendation.save
      
      
    else
      @candy = Candy.find(params[:id])
      @added = false
    end
    
    @result = {:added => @added, :caption => @caption, :message => @message, :candy => @candy} 
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @result}
    end
    #@candy = @user.candies.create({:id => candy.id, :venue_id => params[:venue_id], :pid => candy.pid})
    #@user.candies.save
    #@venue.categories.create(:name => foursquare_data['categories'][0]['name']) if @venue.categories.empty?
  end
  
  def remove_candy
    #CandiesUser.delete_all({:candy_id => params[:id], :user_id => current_user.id})
    
    session[:user_candies_list] = nil
    @candy = Candy.find(params[:id])
    popularity = @candy.score - 1
    
    # Ensure min. score is 0
    @candy.update_attributes({:score => popularity <= 0 ? 0 : popularity});
    
    @recommendation = @candy.recommendations.find_by_user_id(current_user.id)
    @recommendation.update_attributes({:recommended => false})
    
    if params[:venue_id]
    @type = 'venues'
    #redirect_to({:controller => 'venues', :action => 'candies', :id => params[:venue_id]}, :notice => 'Candy removed from your portfolio.')
    else
    @type = 'users'
    #redirect_to({:controller => 'users', :action => 'candies', :id => current_user.id}, :notice => 'Candy removed from your portfolio.')
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => {:type => @type, :candy => @candy} }
    end
    #@candy = @user.candies.create({:id => candy.id, :venue_id => params[:venue_id], :pid => candy.pid})
    #@user.candies.save
    #@venue.categories.create(:name => foursquare_data['categories'][0]['name']) if @venue.categories.empty?
  end
  
  # GET /venues
  # GET /venues.xml
  def index
    authenticate_admin!
    @users = User.order("email ASC").all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
  
  def show
    @user = current_user
    @foursquare = current_user.authentications.where(:provider => 'foursquare').first
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
      format.json { render :json => @user, :only => [:id, :gender, :email] }
    end
  end
  
  def edit
    authenticate_admin!
    @user = User.find(params[:id])
    @foursquare = @user.authentications.where("provider = ?", 'foursquare').first
  end
  
  def update
    @user = User.find(params[:id])
    User.update_foursquare_profile(@user)
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(edit_user_path(params[:id]), :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
    private
    
    # Get scout's score
    def get_score(scout)
      @max = get_max_candy
      @user_score = User.score(current_user)
      
      @scout_score = User.score(scout)
      
      @score_compare = @user_score/Float(@scout_score) * 100
      @score_compare = 100 if @score_compare > 100
      @viewable = @score_compare < 100 ? (@score_compare/Float(100) * @scout_candy_count).floor : @scout_candy_count
      @viewable = @max if @viewable < @max
      
      return @viewable
    end
    
    def get_max_candy
      return 10
    end
    
    def get_scout_candies
      @scout_candies = []
#      @scout_candies = @scout.candies.where("is_candy = ? AND recommended = ?",true, true).order("updated_at DESC").map{|c|
#        display = true 
#        c.recommendations.each do |r|
#        
#          if r.user_id == current_user.id && r.recommended == true
#            display = false
#            break
#          end
#          
#        end
#        next if !display
#        c
#      }
      
      @scout.candies.select("candies.id, candies.is_candy, candies.updated_at, recommended, venue_id, data").where("is_candy = ? AND recommended = ?",true, true).order("updated_at DESC").each do |c|
        display = true 
        c.recommendations.each do |r|
        
          if r.user_id == current_user.id && r.recommended == true
            display = false
            break
          end
          
        end
        
        @scout_candies << c if display
      end
#      @scout_candies = @scout_candies.compact
      
      return @scout_candies
    end
    

end
