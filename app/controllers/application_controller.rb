class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  allow_browser versions: :modern
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :date_of_birth ])

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [
        :username,
        :date_of_birth,
        :bio,
        :location,
        :profile_image,
        :cover_image
      ]
    )
  end
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def after_update_path_for(resource)
    profile_path(resource.username)
  end
end
