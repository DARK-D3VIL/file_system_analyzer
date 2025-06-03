class FilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sftp_session

  def index
    @current_path = session[:selected_folder]
    
    if permitted_params[:path].present?
      @current_path = permitted_params[:path]
    end

    # if @current_path.blank?
    #   raise ActiveRecord::RecordNotFound, "No path provided"
    # end

    @current_path = Pathname.new(@current_path).cleanpath.to_s

    @entries = list_entries(@current_path)

    add_file_records(@entries[:files])
  end

  def destroy
    file_record = find_file(permitted_params[:id])

    if file_record
      delete_file(file_record)
      redirect_to files_path(path: File.dirname(file_record.path)), notice: "File deleted from records. Background deletion in progress."
    else
      redirect_to files_path, alert: "File not found."
    end
  end

  private

  def set_sftp_session
    begin
      if @sftp.nil? || !@sftp&.session&.open?
        @sftp = SftpService.new(current_user).connect
      end
    rescue => e
      reset_session
      flash[:alert] = "Authentication failed: #{e.message}. Please log in again."
      redirect_to root_path
    end
  end

  def list_entries(path)
    folders = []
    files = []

    @sftp.dir.foreach(path) do |entry|
      if ['.', '..'].include?(entry.name)
        next
      end

      full_path = File.join(path, entry.name)

      if entry.directory?
        folders << { name: entry.name, full_path: full_path }
      else
        files << { name: entry.name, full_path: full_path }
      end
    end

    { folders: folders, files: files }
  end

  def permitted_params
    params.permit(:path, :id)
  end

  def find_file(file_id)
    FileRecord.find_by(id: file_id, ephemeral_user_id: current_user.id)
  end

  def delete_file(file_record)
    group = file_record.group

    if group
      group.update(
        saved_size: group.saved_size - file_record.file_size,
        total_files: group.total_files - 1
      )
      if group.total_files <= 0
        group.destroy 
      end
    end

    file_record.destroy
    DeleteFileJob.perform_later(current_user.id, file_record.path)
  end

  def add_file_records(file_entries)
    file_paths = []

    file_entries.each do |entry|
      file_paths << entry[:full_path]
    end

    file_records_query = FileRecord.where(ephemeral_user_id: current_user.id, path: file_paths)
    file_records_query = file_records_query.includes(:tags)
    file_records = file_records_query.to_a
    file_records = file_records.index_by(&:path)
  
    file_entries.each do |entry|
      entry[:record] = file_records[entry[:full_path]]
    end
  end
end
