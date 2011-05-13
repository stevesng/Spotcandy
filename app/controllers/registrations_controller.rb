class RegistrationsController < Devise::RegistrationsController

  # GET /resource/sign_up
  def new
    build_resource({})
    render_with_scope :new
  end
  
  # POST /resource
  def create
    build_resource
    
    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        
        UserMailer.join_mail(resource, User.count).deliver
        # Send welcome email
        UserMailer.welcome_mail(resource.email).deliver
        
        respond_to do |format|
          format.html {respond_with resource, :location => redirect_location(resource_name, resource)}
          format.json  { render :json => resource, :callback => params[:callback] }
        end
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render_with_scope :new }
    end
  end
  
  def build_resource(*args)
    super
    if session[:auth]
      @user.apply_auth(session[:auth])
      @user.valid?
    end
  end
end