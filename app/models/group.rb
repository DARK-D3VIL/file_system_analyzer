class Group < ApplicationRecord
  has_many :file_records

  validates :content_hash, presence: true, uniqueness: true
end