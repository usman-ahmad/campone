class Group < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { scope: :type }
end