class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :project_group

  has_many :tasks
  has_many :discussions
  has_many :invitations
  has_many :members, through: :invitations, :source => :user

  validates :name, presence: true
end
