class ApplicationController < ActionController::Base
  helper_method :current_user
  def current_user
    @current_user ||= EphemeralUser.find_by(id: session[:ephemeral_user_id])
  end

  def authenticate_user!
    if !current_user.present?
      redirect_to login_path 
    end
  end
end
