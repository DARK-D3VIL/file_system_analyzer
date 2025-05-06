class Tag < ApplicationRecord
  belongs_to :file_record

  validates :tag_name, presence: true
end
