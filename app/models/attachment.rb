class Attachment < ApplicationRecord
  has_attached_file :attachment,
                    styles:
                        lambda { |a|
                          puts "aaaaaaaaa#{a.inspect}"
                          if a.instance.is_image?
                            { thumb: "100x100#" }
                          elsif a.instance.is_video?
                            { thumb: { geometry: "100x100#", format: 'jpg', time: 10 }}
                          else
                            {}
                          end
                        },
                    default_url: '/images/:style/missing_file_type.png',
                    processors: lambda { |a| a.is_video? ? [ :transcoder ] : [ :thumbnail ] }



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

  def is_image?
    attachment_content_type.match('image.*')
  end

  def is_video?
    attachment_content_type.match('video.*')
  end
end
