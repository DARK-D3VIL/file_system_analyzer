class BrowseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sftp_session

  def index
    @current_path = '.'
    if permitted_params[:path].presence
      @current_path = params[:path]
    end
    # puts params[:path]
    @current_path = normalize_path(@current_path)
    @entries = list_folders(@current_path)
  end

  def select
    selected_path = params[:path]
    session[:selected_folder] = selected_path
    FetchDataJob.perform_later(current_user.id, selected_path)
    redirect_to dashboard_path, notice: "Folder selected: #{selected_path}"
  end

  private

  def set_sftp_session
    if @sftp.nil? || !@sftp&.session&.open?
      @sftp = SftpService.new(current_user).connect
    end
    @sftp
  end

  def permitted_params
    params.permit(:path)
  end

  def list_folders(path)
    begin
      res = []
      @sftp.dir.foreach(path) do |entry|
        if entry.name != '.' && entry.name != '..' && entry.directory? && entry.name[0] != '.'
          res << entry
        end
      end
      res
    rescue StandardError => e
      flash[:alert] = "Error accessing folder: #{e.message}"
      []
    end
  end

  def normalize_path(path)
    Pathname.new(path).cleanpath.to_s
  end
end
