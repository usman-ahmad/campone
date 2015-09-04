class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :project_group

  has_many :tasks
  has_many :discussions
  has_many :invitations
  has_many :members, through: :invitations, :source => :user

  validates :name, presence: true

  accepts_nested_attributes_for :project_group, :reject_if => proc { |attributes| attributes['name'].blank? }
end
