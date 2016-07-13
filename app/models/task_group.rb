class TaskGroup < Group
  has_many :tasks
  belongs_to :project

  scope :list_for, ->(project) { where(project_id: project.id) }
end
