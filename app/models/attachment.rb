class Attachment < ActiveRecord::Base
  has_attached_file :attachment

  belongs_to :project
  belongs_to :commentable, polymorphic: true

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/jpeg image/gif image/png application/pdf text/plain ]

  validates_attachment :attachment, presence: true,
      content_type: { content_type: ALLOWED_CONTENT_TYPES},
      size: { in: 0..20.megabytes}
end
