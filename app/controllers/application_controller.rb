class ApplicationController < ActionController::Base
  layout 'mobile'
  protect_from_forgery
  
  @@auth = Authentication.get_keys
  @@send_email = true
  
  def after_sign_in_path_for(resource_or_scope)

    if current_user
    
      # Import user's foursquare venues
      # Venue.init_venue_history(current_user)
      
      # Update user's foursquare profile
      foursquare = User.update_foursquare_profile(current_user)

      auth = {'foursquare' =>  foursquare[:access_token]}
      session[:oauth] = auth
      # Sends email
      # email = UserMailer.welcome_email.deliver
            #Send email notification
      
      #current_user.add_nice_as_friend
      my_foursquare = current_user.authentications.first
       
      if my_foursquare && current_user.gender == 'female'
      session[:is_female] = my_foursquare.uid
      {:controller => 'candies', :action => 'profile', :pid => my_foursquare.uid}
      #destroy_user_session_path
      else
      session[:is_female] = nil
      root_url
      end
      
    else
      admin_index_path
    end
  end
  
  def init_variables
    @host_url = 'http://spotcandy.com.localhost:3000'
    @remote_host_url = 'm.spotcandy.com'
    @candies_photo_path = "/images/candies"
    @email_noreply = "noreply@spotcandy.com"
  end

  def refresh_oauth
    if current_user && session[:oauth].nil?
      foursquare = User.update_foursquare_profile(current_user)

      auth = {'foursquare' =>  foursquare[:access_token]}
      session[:oauth] = auth
    end
  end
  
end
