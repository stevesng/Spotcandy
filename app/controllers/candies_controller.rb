class CandiesController < ApplicationController
  layout 'application'
  
  def cleanup
    
    @list = []
    Candy.where("score = 0 AND flag_status = 0").order("created_at").limit(500).each do |c|
      diff = (Time.now.to_i - c.created_at.to_i)/(60*60*24)
      if diff >= 14
        c.flag_status = 2
        c.save
        @list << c.id
      end
    end
    
  end
  
  def privileges
    render :layout => 'mobile'
  end
  
  def profile
    @candy = Candy.find_by_pid(params[:pid])
    render :layout => 'mobile'
  end
  
  def display
    @candy = Candy.find(params[:id])
    render :layout => false
  end
  
  def grid
    #rand_id = rand(Candy.count)
    if params[:type] == 'nearby'
      @candies = Candy.where("is_candy = true").limit(15).order("created_at DESC").find_all_by_venue_id(session[:trending])
    end
    
    if params[:type] == 'recent'
      order = "created_at DESC"
      @candies = Candy.where("is_candy = true").order(order).limit(15)
    end
    
    if params[:type] == 'popular'
      order = "score DESC"
      @candies = Candy.where("is_candy = true AND score > 1").order(order)
      @candies = @candies.sort_by{rand}.slice(0,15)
    end
    
    if params[:type].nil?
      @candies = Candy.where("is_candy = true").order("RANDOM()").limit(15)
    end

    respond_to do |format|
      format.html { render :layout => false }
      format.json  { render :json => @candies }
    end
  end
  
  def detail
    authenticate_user!
    @candy = Candy.find(params[:id])
    respond_to do |format|
      format.html {render :layout => false}
      format.json  { render :json => @candy }
    end
  end
  
  def update_profile
    @candy = Candy.find(params[:id])
    
    @@auth = Authentication.get_keys
    
    refresh_photo = true
    
    #access_token = User.find_by_email('wilson@spotcandy.com').authentications.where("provider = ?",'foursquare').first.access_token
    foursquare_candy = JSON.parse(Authentication.req('foursquare').request(
    :get, "https://api.foursquare.com/v2/users/#{@candy.pid}",
    :client_id => @@auth[:key],
    :client_secret => @@auth[:secret],
    :oauth_token => session[:oauth]['foursquare']
    ))
      
    @candy.data['photo'] = foursquare_candy['response']['user']['photo']
    @candy.save

    # Save photos with paperclip for candy
    candy_photos = @candy.photos
    
    if @candy.is_candy && !candy_photos.empty?
      candy_current_photo = @candy.data['photo'].gsub('userpix_thumbs', 'userpix')
      
      # New Foursquare Photo
      if @candy.photos.find_by_photo_file_name(candy_current_photo[-20,20]).nil?
      attr = {:default_photo => @candy.photos.first.id, :photos_attributes => {@candy.photos.count => {:photo_remote_url => candy_current_photo}}}
      @candy.update_attributes(attr);
      refresh_photo = true
      else
      refresh_photo = false
      end

    end
    
    if refresh_photo
      pic = @candy.data['photo'].gsub('userpix_thumbs', 'userpix')
      thumbnail = @candy.data['photo']
    else
      pic = @candy.get_pic('original')
      thumbnail = @candy.get_pic('thumbnail')
    end
    
    respond_to do |format|
      format.json  { render :json => {:candy => @candy, :pic => pic, :thumbnail => thumbnail} }
    end
  end
  
  def flag
    @candy = Candy.find(params[:id])

    # Notified only if never flagged before
    if @candy.flag_status == 0
      if @candy.recommendations.where("recommended = ?", true).empty? || current_user.verified
        @candy.flag_status = 2
        @candy.save
      else
        flag_mail = UserMailer.flag_mail(@candy, current_user).deliver
      end
    else
      @candy = nil
    end
#    redirect_to({:controller => 'venues', :action => 'candies', :id => params[:venue_id], 
#    :anchor => "candy_#{params[:id]}"}, :notice => "We have been notified.")
    render :json => {:result => @candy}
#    respond_to do |format|
#      format.html # index.html.erb
#      format.json  { render :json => {:notified => @notified} }
#    end
  end
  
  # GET /candies
  # GET /candies.xml
  def index
    authenticate_admin!
    
    @candies = Candy.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @candies }
    end
  end

  # GET /candies/1
  # GET /candies/1.xml
  def show
    #authenticate_admin!
    #require 'open-uri'
    
    @candy = Candy.find(params[:id])
    @candy_photo = @candy.data['photo']
    @photo = @candy.photos.first
    
#    dir_pic = "#{RAILS_ROOT}/public/images/candies/#{@candy.id}"
#      
#    FileUtils.mkdir_p dir_pic if !File.directory?(dir_pic)
#    open(@candy_photo) do |o|
#      File.open("#{dir_pic}/#{@candy.pid}.jpg", "w") { |f| f << o.read }
#    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @candy }
      format.json  { render :json => @candy }
    end
  end

  # GET /candies/new
  # GET /candies/new.xml
  def new
    @candy = Candy.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @candy }
    end
  end

  # GET /candies/1/edit
  def edit
    authenticate_admin!
    @candy = Candy.includes(:users, {:venue => :users}).find(params[:id])

    @watchers = @candy.venue.users.where("watched = true")
    
  end

  # POST /candies
  # POST /candies.xml
  def create
    @candy = Candy.new(params[:candy])

    respond_to do |format|
      if @candy.save
        format.html { redirect_to(@candy, :notice => 'Candy was successfully created.') }
        format.xml  { render :xml => @candy, :status => :created, :location => @candy }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @candy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /candies/1
  # PUT /candies/1.xml
  def update
  
    @candy = Candy.includes(:users, {:venue => :users}).find(params[:id])
    
    if params[:send_mail] && params[:candy][:is_candy] == '1' && !@candy.is_candy
      @watchers = @candy.venue.users.where("watched = true")
      
      rand_id = rand(Candy.count)
      @watchers.each do |w|
        UserMailer.watch_new_candy_mail(w.email, @candy, rand_id).deliver if @candy.users.find_by_id(w.id).nil?
      end
      
    end
    
    if params[:candy][:facebook_update] == '1' && !@candy.facebook_update
    
      @facebook_page = Variable.find_by_name('facebook')
      
      if @facebook_page
        auth = Authentication.get_keys('facebook')
      
        @facebook_obj = JSON.parse(Authentication.req('facebook').request(
        :post, "https://graph.facebook.com/spotcandy/feed",
        :message => "Candy of the day spotted @\n#{@candy.venue.name}, #{@candy.venue.location['state']}",
        :picture => @candy.get_pic('thumbnail'),
        :name => "Candy of the Day",
        :description => "The world's most attractive people.",
        :link => "http://spotcandy.com/venue/#{@candy.venue.id}/candies",
        :caption => "http://m.spotcandy.com",
        :client_id => auth[:key],
        :client_secret => auth[:secret],
        :oauth_token => @facebook_page[:value]))
      end
      
    end
    
    @candy.update_attributes(params[:candy])
    
    if params[:candy][:flag_status] == '2' || params[:candy][:rejected] == '1'
      @candy.photos.destroy_all if !@candy.photos.empty?
      
#      params[:candy]['data'] = @candy.data
#      params[:candy]['data']['photo'] = @foursquare_candy['response']['user']['photo']
    end
    
    # Save photo with paperclip
#    photo = @candy.photos.first
#    
#    if photo
#      photo.photo_remote_url = @foursquare_candy['response']['user']['photo']
#      photo.save
#    else
#      params[:candy]['photos_attributes'] = {0 => {:photo_remote_url => @foursquare_candy['response']['user']['photo']}}
#      @candy.update_attributes(params[:candy])
#    end
    
    
    
    redirect_to(@candy, :notice => 'Candy was successfully updated.')
    
#    respond_to do |format|
#      if @candy.update_attributes(params[:candy])
##        format.html { redirect_to(@candy, :notice => 'Candy was successfully updated.') }
##        format.xml  { head :ok }
#        format.html { render :action => "edit" }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @candy.errors, :status => :unprocessable_entity }
#      end
#    end
  end

  # DELETE /candies/1
  # DELETE /candies/1.xml
  def destroy
    @candy = Candy.find(params[:id])
    @candy.destroy

    respond_to do |format|
      format.html { redirect_to(candies_url) }
      format.xml  { head :ok }
    end
  end
end
