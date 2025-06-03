class EphemeralUser < ApplicationRecord
  validates :username, :host, :encrypted_password, presence: true
  has_many :file_records, dependent: :destroy
  
  def password=(raw_password)
    self.encrypted_password = ENCRYPTOR.encrypt_and_sign(raw_password)
  end

  def password
    begin
      ENCRYPTOR.decrypt_and_verify(encrypted_password)
    rescue StandardError
      nil
    end
  end
end
