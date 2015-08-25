class Task < ActiveRecord::Base
  belongs_to :project

  enum priority: [:low, :medium, :high ]
end
