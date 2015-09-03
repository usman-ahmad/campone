class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :task_group

  has_many :comments, as: :commentable

  enum priority: [:low, :medium, :high ]
end
