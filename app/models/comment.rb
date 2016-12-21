# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  commentable_id   :integer
#  commentable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#

class Comment < ApplicationRecord
  include PublicActivity::Common

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_many :attachments, as: :attachable, dependent: :destroy

  # COMMENTABLE_TYPES = %w(Task Discussion ProjectAttachment_AS_Attachment)

  validates :content, presence: true

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      # attachments.build(:attachment => file, project: self.commentable_type.constantize.find(self.commentable_id).project, user_id: self.user_id  )
      attachments.build(:document => file, project: self.commentable.project, user_id: self.user_id  )
    end
  end

  def project
    self.commentable.project # self.attachable >>> [task discussion attachment]
  end
end
