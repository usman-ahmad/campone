# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :integer
#  document_updated_at   :datetime
#  description           :text
#  attachable_id         :integer
#  attachable_type       :string
#  project_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  uploader_id           :integer
#  title                 :string
#  type                  :string
#

class ProjectAttachment < Attachment
  has_many :comments, as: :commentable, dependent: :destroy

  ATTACHABLE_TYPES = %w(Project)

  validates_presence_of :title

  def self.model_name
    Attachment.model_name
  end

  def project
    self.attachable
  end
end
