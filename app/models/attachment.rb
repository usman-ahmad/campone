# == Schema Information
#
# Table name: attachments
#
#  id                      :integer          not null, primary key
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  description             :text
#  attachable_id           :integer
#  attachable_type         :string
#  project_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#  title                   :string
#

class Attachment < ApplicationRecord

  has_attached_file :attachment,
                    styles:
                        lambda { |a|
                          if a.instance.is_image?
                            {thumb: '100x100#'}
                          elsif a.instance.is_video?
                            {thumb: {geometry: '100x100#', format: 'jpg', time: 10}}
                          else
                            {}
                          end
                        },
                    default_url: '/images/:style/missing_file_type.png',
                    processors: lambda { |a| a.is_video? ? [:transcoder] : [:thumbnail] }


  belongs_to :project
  belongs_to :attachable, polymorphic: true
  belongs_to :uploader, class_name: User, foreign_key: :user_id

  # TODO BLACKLIST ALL EXECUTABLE FILES
  NOT_ALLOWED_CONTENT_TYPES = %w[application/x-msdownload] # exe

  # UA[2016/12/08] - NEED 'validates_presence_of :title' FOR PROJECT ATTACHMENTS ONLY
  # validates_presence_of :title

  validates_attachment :attachment, presence: true,
                       content_type: {:not => NOT_ALLOWED_CONTENT_TYPES, message: 'should NOT be executable.'},
                       size: {in: 0..20.megabytes, message: 'should NOT be greater than 20MB.'}

  def attach_from_url(url)
    self.attachment = URI.parse(url)
  end

  def is_image?
    attachment_content_type.match('image.*')
  end

  def is_video?
    attachment_content_type.match('video.*')
  end
end
