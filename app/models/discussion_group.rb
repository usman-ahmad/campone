class DiscussionGroup < Group
  has_many :discussions
  belongs_to :project

  scope :list_for, ->(project) { where(project_id: project.id) }
end