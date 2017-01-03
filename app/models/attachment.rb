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

class Attachment < ApplicationRecord

  has_attached_file :document,
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
                    path: ':rails_root/public/system/attachments/documents/:id_partition/:style/:filename',
                    url: '/system/attachments/documents/:id_partition/:style/:filename',
                    processors: lambda { |a| a.is_video? ? [:transcoder] : [:thumbnail] }

  belongs_to :project
  belongs_to :attachable, polymorphic: true
  belongs_to :uploader, class_name: User, foreign_key: :uploader_id

  ATTACHABLE_TYPES = %w(Task Discussion Comment)
  # TODO BLACKLIST ALL EXECUTABLE FILES
  NOT_ALLOWED_CONTENT_TYPES = %w[application/x-msdownload] # exe

  attr_accessor :attachment_name
  attr_accessor :performer

  # validates_inclusion_of :attachable_type, in: ATTACHABLE_TYPES
  validates_inclusion_of :attachable_type, in: Proc.new { |a| a.class::ATTACHABLE_TYPES }
  validates_presence_of :attachment_name, on: :update

  validates_attachment :document, presence: true,
                       content_type: {:not => NOT_ALLOWED_CONTENT_TYPES, message: 'should NOT be executable.'},
                       size: {in: 0..20.megabytes, message: 'should NOT be greater than 20MB.'}

  def attachment_name
    @attachment_name || (File.basename(document_file_name, File.extname(document_file_name)) if document.present?)
  end

  def attach_from_url(url)
    self.document = URI.parse(url)
  end

  def is_image?
    !!document_content_type.match('image.*')
  end

  def is_video?
    !!document_content_type.match('video.*')
  end

  def project
    self.attachable.project # self.attachable >>> [task discussion comment]
  end

  before_update :update_file_name

  def update_file_name
    return if @attachment_name.blank?

    extension = File.extname(self.document_file_name)
    new_file_name = @attachment_name + extension

    (self.document.styles.keys + [:original]).each do |style|
      file_name_with_path = self.document.path(style)
      directory = File.dirname(file_name_with_path)

      if file_name_with_path != File.join(directory, new_file_name)
        FileUtils.move(file_name_with_path, File.join(directory, new_file_name))
      end
    end

    self.document_file_name = new_file_name
  end
end
