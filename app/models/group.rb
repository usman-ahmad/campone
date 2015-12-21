class Group < ActiveRecord::Base

  # TODO: Should be unique only for a project 
  validates :name, presence: true, uniqueness: { scope: :type }
end