class SftpService
  def initialize(user)
    @host = user.host
    @username = user.username
    @password = user.password
    @port = user.port
  end

  def connect
    begin
      Timeout.timeout(10) do
        Net::SFTP.start(@host, @username, password: @password, port: @port) do |sftp|
          return sftp
        end
      end
    rescue Timeout::Error
      raise "SSH connection timed out. The server may be unresponsive or the credentials may be incorrect."
    rescue Net::SFTP::Exception => e
      raise "SFTP connection failed: #{e.message}"
    rescue StandardError => e
      raise "Connection error: #{e.message}"
    end
  end

  def ssh_session
    Net::SSH.start(@host, @username, password: @password, port: @port)
  end
end
