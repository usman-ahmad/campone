class AttachmentGroup < Group
  has_many :attachments
  has_many :projects, through: :attachments

  scope :list_for, ->(project) { joins(:projects).where('projects.id = ?', project.id) }
end
