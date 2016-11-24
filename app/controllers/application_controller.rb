class ApplicationController < ActionController::Base

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :ensure_signup_complete

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    redirect_back fallback_location: root_url, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    projects_path
  end

  protected

  def configure_permitted_parameters
    # (in devise 4.0.0) devise_parameter_sanitize API has changed and "for" method was deprecated in favor of "permit"
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
  end

  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup' || 'associate_account'

    if current_user && encrypted_password.blank?
      redirect_to finish_signup_path(current_user)
    end
  end

  def importable?(name)
    %w[trello jira asana].include? name
  end
end
