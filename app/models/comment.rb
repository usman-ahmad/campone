class Comment < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_many :attachments, as: :attachable

  validates :content, presence: true

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:attachment => file, project: self.commentable_type.constantize.find(self.commentable_id).project, user_id: self.user_id  )
    end
  end
end
