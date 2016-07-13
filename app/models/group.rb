class Group < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  # TODO: Do not create new group if already existing
  validates :name, presence: true

  def to_s
    name
  end

  scope :case_insensitive, ->(key,value) { where("lower(#{key}) = ?", value.downcase) }
end