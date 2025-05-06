key = [Rails.application.credentials.encryption_key].pack("H*")
ENCRYPTOR = ActiveSupport::MessageEncryptor.new(key, cipher: "aes-256-gcm")
