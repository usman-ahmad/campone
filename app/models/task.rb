class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :task_group

  has_many :comments, as: :commentable

  enum priority: [:low, :medium, :high ]

  validates :title, presence: true
  accepts_nested_attributes_for :task_group, :reject_if => proc { |attributes| attributes['name'].blank? }
end
