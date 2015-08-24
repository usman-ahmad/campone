class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'

  validates :name, presence: true
end
