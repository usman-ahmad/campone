class Attachment < ApplicationRecord
  has_attached_file :attachment

  belongs_to :project
  belongs_to :attachable, polymorphic: true
  belongs_to :uploader, class_name: User, foreign_key: :user_id

  # TODO BLACKLIST ALL EXECUTABLE FILES
  NOT_ALLOWED_CONTENT_TYPES = %w[application/x-msdownload] # exe

  validates_attachment :attachment, presence: true,
      content_type: { :not => NOT_ALLOWED_CONTENT_TYPES, message: 'should NOT be executable.' },
      size: { in: 0..20.megabytes, message: 'should NOT be greater than 20MB.' }

  def attach_from_url(url)
    self.attachment = URI.parse(url)
  end
end
