class Comment < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  has_many :attachments, as: :attachable


  def commentable
    self.commentable_type.constantize.find(commentable_id)
  end

  validates :content, presence: true

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:attachment => file, project: self.commentable_type.constantize.find(self.commentable_id).project  )
    end
  end
end
