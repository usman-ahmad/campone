class ProjectGroup < Group
  has_many :projects

  scope :list_for, ->(user) { where(creator_id: user.id) }
end
