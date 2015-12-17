class Comment < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  has_many :attachments, as: :attachable


  def commentable
    self.commentable_type.constantize.where(id:commentable_id).first
  end

  validates :content, presence: true

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:attachment => file, project: self.commentable_type.constantize.find(self.commentable_id).project, user_id: self.user_id  )
    end
  end
end
