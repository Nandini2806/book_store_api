class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def get_current_user
    if user_signed_in?
      return current_user
    end
  end

  def configure_permitted_parameters
    added_attrs = [:user_name, :full_name, :role]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

end
