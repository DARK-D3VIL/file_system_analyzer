class DeleteFileJob < ApplicationJob
  queue_as :default

  def perform(user_id, file_path)
    user = EphemeralUser.find_by(id: user_id)
    if !user
      return
    end
    sftp = SftpService.new(user).connect
    sftp.remove!(file_path)
  rescue => e
    Rails.logger.error("Failed to delete file #{file_path} from SFTP: #{e.message}")
  end
end
