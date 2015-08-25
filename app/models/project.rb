class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_many :tasks

  validates :name, presence: true
end
