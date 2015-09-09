class Attachment < ActiveRecord::Base
  has_attached_file :attachment

  belongs_to :project
  belongs_to :commentable, polymorphic: true

  do_not_validate_attachment_file_type :attachment
end
