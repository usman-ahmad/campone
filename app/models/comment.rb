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
  # include PublicActivity::Common

  include Notifiable
  # TODO: VIP Fix. Commentable has many comments, we are using dependent destroy, commentable is deleted first, then comments
  # While deleting comments we have no reference to commentable, hence notification system is broken
  # Do not notify if commentable is deleted.
  act_as_notifiable performer: :performer,
                    receivers: :notification_receivers,
                    content_method: :content,
                    notifiable_integrations: Proc.new { |comment| comment.project.integrations.notifiable if comment.commentable.present? }

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_many :attachments, as: :attachable, dependent: :destroy

  # COMMENTABLE_TYPES = %w(Task Discussion ProjectAttachment_AS_Attachment)

  validates :content, presence: true

  before_create :set_user
  attr_accessor :performer

  def notification_performer
    user
  end

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      # attachments.build(:attachment => file, project: self.commentable_type.constantize.find(self.commentable_id).project, user_id: self.user_id  )
      attachments.build(:document => file, project: self.commentable.project, uploader_id: self.user_id)
    end
  end

  def project
    self.commentable.project # self.attachable >>> [task discussion attachment]
  end

  private

  def set_user
    self.user = performer
  end

  def notification_receivers
    # if commentable is deleted then do not notify
    commentable.send(:notification_receivers) - [performer] if commentable
  end
end
