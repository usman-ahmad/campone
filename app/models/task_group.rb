class TaskGroup < Group
  has_many :tasks

  scope :list_for, ->(project) { joins(:tasks).where("tasks.project_id = ? ", project.id) }
end