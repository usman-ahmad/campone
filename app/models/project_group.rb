class ProjectGroup < Group
  has_many :projects

  scope :list_of, ->(owner) { joins(:projects).where("projects.owner_id = ? ", owner.id) }
end
