class RegistrationsController < Devise::RegistrationsController
 def create
    #super
    build_resource

    if resource.save
      set_flash_message :notice, :signed_up
      # Email admin
      UserMailer.join_mail(resource, User.count).deliver
      # Send welcome email
      UserMailer.welcome_mail(resource.email).deliver
      sign_in_and_redirect(resource_name, resource)
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
    
    session[:auth] = nil unless @user.new_record?
    #UserMailer.join_mail(@user, User.count).deliver if session[:auth]
  end
  
  private
  
  def build_resource(*args)
    super
    if session[:auth]
      @user.apply_auth(session[:auth])
      @user.valid?
    end
  end
end