class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  def configure_permitted_parameters
    # For sign up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :date_of_birth])
    
    # For account update (optional)
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :date_of_birth])
  end
  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
