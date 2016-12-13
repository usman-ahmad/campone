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
#  type                    :string
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
                    path: ':rails_root/public/system/attachments/attachments/:id_partition/:style/:filename',
                    url: '/system/attachments/attachments/:id_partition/:style/:filename',
                    processors: lambda { |a| a.is_video? ? [:transcoder] : [:thumbnail] }

  belongs_to :project
  belongs_to :attachable, polymorphic: true
  belongs_to :uploader, class_name: User, foreign_key: :user_id

  ATTACHABLE_TYPES = %w(Task Discussion Comment)

  attr_accessor :attachment_name

  # TODO BLACKLIST ALL EXECUTABLE FILES
  NOT_ALLOWED_CONTENT_TYPES = %w[application/x-msdownload] # exe

  # validates_inclusion_of :attachable_type, in: ATTACHABLE_TYPES
  validates_inclusion_of :attachable_type, in: Proc.new { |a| a.class::ATTACHABLE_TYPES }
  validates_presence_of :attachment_name, on: :update

  validates_attachment :attachment, presence: true,
                       content_type: {:not => NOT_ALLOWED_CONTENT_TYPES, message: 'should NOT be executable.'},
                       size: {in: 0..20.megabytes, message: 'should NOT be greater than 20MB.'}

  def attachment_name
    @attachment_name || (File.basename(attachment_file_name, File.extname(attachment_file_name)) if attachment.present?)
  end

  def attach_from_url(url)
    self.attachment = URI.parse(url)
  end

  def is_image?
    !!attachment_content_type.match('image.*')
  end

  def is_video?
    !!attachment_content_type.match('video.*')
  end

  def project
    self.attachable.project # self.attachable >>> [task discussion comment]
  end

  before_update :update_file_name

  def update_file_name
    return if @attachment_name.blank?

    extension = File.extname(self.attachment_file_name)
    new_file_name = @attachment_name + extension

    (self.attachment.styles.keys + [:original]).each do |style|
      file_name_with_path = self.attachment.path(style)
      directory = File.dirname(file_name_with_path)

      if file_name_with_path != File.join(directory, new_file_name)
        FileUtils.move(file_name_with_path, File.join(directory, new_file_name))
      end
    end

    self.attachment_file_name = new_file_name
  end
end
