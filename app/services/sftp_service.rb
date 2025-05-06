class SftpService
  def initialize(user)
    @host = user.host
    @username = user.username
    @password = user.password
    @port = user.port
  end

  def connect
    Net::SFTP.start(@host, @username, password: @password, port: @port)
  end

  def ssh_session
    Net::SSH.start(@host, @username, password: @password, port: @port)
  end
end
