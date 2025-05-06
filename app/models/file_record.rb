class FileRecord < ApplicationRecord
  belongs_to :ephemeral_user

  belongs_to :group, optional: true
  has_many :tags, dependent: :destroy

  validates :path, presence: true
  validates :path, uniqueness: { scope: :ephemeral_user_id }

  def duplicate?
    is_duplicate
  end
  
  def anomalous?
    is_anomalous
  end
  
  def archivable?
    is_archivable
  end
end
