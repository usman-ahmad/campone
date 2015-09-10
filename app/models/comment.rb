class Comment < ActiveRecord::Base
  belongs_to :user

  has_many :comments,    as: :commentable
  has_many :attachments, as: :attachable

  validates :content, presence: true

  def attachments_array=(array)
    array.each do |file|
      attachments.build(:attachment => file, project: self.commentable_type.constantize.find(self.commentable_id).project  )
    end
  end
end
