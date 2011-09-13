class AuthenticationsController < ApplicationController
  before_filter :init_variables
  
  # Foursquare
  def index
    
#    session[:oauth] = nil if params[:clear]
#    session[:oauth] = {'foursquare' => nil, 'facebook' => nil} if session[:oauth].nil?
    
    provider = params[:provider]
    
    #oauth_url = request.env['HTTP_HOST'] == 'spotcandy.com.localhost:3000' ? 'spotcandylocal.com' : @remote_host_url
    oauth_url = '127.0.0.1:3000'
    options = {:redirect_uri => "http://#{oauth_url}/auth/#{provider}/callback"}
    options[:scope] = 'email,publish_stream,read_stream,user_photos,user_checkins,friends_checkins,manage_pages' if provider == 'facebook'
    
    redirect_to Authentication.req(provider).web_server.authorize_url(options)
    
  end
  
  def callback
    
    redirect_to root_url and return if !params[:code]
        
    if params[:error]
    
      redirect_to user_session_path 
      
    else
      #@client = Authentication.authenticate
      provider = params[:provider]
      #oauth_url = request.env['HTTP_HOST'] == 'spotcandy.com.localhost:3000' ? 'spotcandylocal.com' : @remote_host_url
      oauth_url = '127.0.0.1:3000'
      access_token = Authentication.req(provider).web_server.get_access_token(
        params[:code], :redirect_uri => "http://#{oauth_url}/auth/#{provider}/callback"
      )
      
      case provider
        when "foursquare"
          user = JSON.parse(Authentication.req(provider).request(:get, "https://api.foursquare.com/v2/users/self", 
          :oauth_token => access_token.token))

          uid = user['response']['user']['id'].to_i
          user_email = user['response']['user']['contact']['email']
          user_data = user['response']['user']
          
        when "facebook"
          user = JSON.parse(access_token.get('/me'))
          uid = user['id']
          user_email = user['email']
          user_data = user
      end
      
      @user = user
      
      auth = {
      :provider => provider,
      :uid => uid,
      :access_token => access_token.token,
      :data => user_data,
      :email => user_email}
      
      authentication = Authentication.find_by_provider_and_uid(provider, uid)
      
      if authentication
        flash[:notice] = "Signed in successfully."
        authentication.update_attributes(:data => user_data)

        authentication.user.gender = user_data['gender']
        authentication.user.save
          
        sign_in_and_redirect(:user, authentication.user)
      else
        
        # Link to account
        if current_user
          current_user.apply_auth(auth)
          if current_user.save
            flash[:notice] = "#{provider.capitalize} account linked successfully!"
            session[:oauth] = {provider => auth[:access_token]}
            
            if provider == 'facebook'
              @facebook_page = Variable.find_by_name('facebook')
              auth = Authentication.get_keys('facebook')
              
              if !@facebook_page
                
                @facebook_obj = JSON.parse(Authentication.req('facebook').request(
                :get, "https://graph.facebook.com/me/accounts",
                :client_id => auth[:key],
                :client_secret => auth[:secret],
                :oauth_token => Authentication.where("provider = ?",'facebook').first.access_token))
              
                @facebook_obj['data'].each do |p|
                  if p['category'] == 'Website' && p['name'] == 'Spotcandy'
                    v = Variable.new({:name => 'facebook', :value => p['access_token']})
                    v.save
                  end
                end
              end
            end
#            
#            session[:oauth] = auth

            redirect_to root_url
            #sign_in_and_redirect(:user, current_user)
          end
          
        else
          # Check whether user account already exists
          if !User.find_by_email(user_email)
            user = User.new
            user.apply_auth(auth)
            
            if user.save
              flash[:notice] = "Signed in successfully."
              sign_in_and_redirect(:user, user)
            else
              session[:auth] = auth.except('extra')
              redirect_to new_user_registration_url
            end
            
          end
        
        end
        
      end
      
    end
    
  end
  
end
