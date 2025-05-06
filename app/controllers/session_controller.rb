class SessionController < ApplicationController
  def new
  end

  def create
    host = params[:host]
    username = params[:username]
    password = params[:password]
    port = params[:port] || 22

    @user = EphemeralUser.new(host: host, username: username, password: password, port: port)

    if @user.save
      session[:ephemeral_user_id] = @user.id
      redirect_to browse_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Login failed. Please check your details."
      render :new
    end
  end

  def destroy
    if session[:ephemeral_user_id]
      user_id = session[:ephemeral_user_id]
      DataCleanJob.perform_later(user_id)
      reset_session
    end
    
    redirect_to login_path, notice: "Logged out successfully."
  end

  private

  def user_params
    params.permit(:username, :host, :port, :password)
  end
end
