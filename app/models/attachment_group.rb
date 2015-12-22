class AttachmentGroup < Group
  has_many :attachments
  belongs_to :project

  scope :list_for, ->(project) { where(project_id: project.id) }
end
