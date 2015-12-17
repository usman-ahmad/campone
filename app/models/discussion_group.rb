class DiscussionGroup < Group
  has_many :discussions

  scope :list_for, ->(project) { joins(:discussions).where("discussions.project_id = ? ", project.id) }
end