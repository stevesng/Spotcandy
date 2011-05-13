class PagesController < ApplicationController
  def home
    #email = UserMailer.welcome_email.deliver
    #@candies = CandiesUser.limit(50).order("updated_at DESC").find( :all, :select => 'DISTINCT candy_id' )
    #@candies = CandiesUser.limit(50).order("updated_at DESC").find( :all, :group => 'candy_id' )
#    Candy.limit(50).select("id,pid,data,created_at,updated_at,score,venue_id,is_candy,rejected,flag_status").where("score > ?", 0).group("id").order("created_at")
    if !current_user
      @candies = Candy.includes(:venue,:photos).where("score > 0 AND is_candy = true").order("created_at DESC").limit(30)
      #@candies = Candy.find_by_sql("SELECT * FROM candies WHERE score > 0 AND is_candy = true ORDER BY created_at desc LIMIT 30")
      render :layout => 'mobile_home' and return
    else
      session[:venue_back] = 'venues'
    end
    
#    auth = Authentication.get_keys('facebook')
#    
#    lat = 1.2949353580
#    lng = 103.8596606255
#    @facebook_obj = JSON.parse(Authentication.req('facebook').request(
#    :get, "https://graph.facebook.com/111071872304611/checkins",
#    :client_id => auth[:key],
#    :client_secret => auth[:secret],
#    :oauth_token => Authentication.where("provider = ?",'facebook').first.access_token))
    
    redirect_to destroy_user_session_path if current_user && session[:oauth].nil?
    

    
    
  end
  
  def faq
  end
  
  def female
    @candy = Candy.find_by_pid(params[:pid])
  end
  
  def stream
    session[:venue_back] = 'stream'
    @candies = Candy.includes(:venue,:photos).where("score > 0 AND is_candy = true").order("created_at DESC").limit(30)
#    @candies = Candy.includes(:venue,:photos).find_by_sql("SELECT * FROM candies WHERE score > 0 AND is_candy = true ORDER BY created_at desc LIMIT 20")
  end
  
  def candies
    layout = current_user ? 'mobile' : 'mobile_home'
    render :layout => layout
  end
  
  def test
    authenticate_admin!
    @s = "https://playfoursquare.s3.amazonaws.com/userpix_thumbs/AAIEVYRFQRBJVUZE.jpg"
    render :layout => false
  end
  
end
