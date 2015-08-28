class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_many :tasks
  has_many :discussions
  has_many :invitations
  has_many :members, through: :invitations, :source => :user
  validates :name, presence: true
end
