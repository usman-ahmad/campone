class Task < ActiveRecord::Base
  belongs_to :project
  has_many :comments, as: :commentable

  enum priority: [:low, :medium, :high ]
end
