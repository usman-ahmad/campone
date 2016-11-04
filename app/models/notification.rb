class Notification < ApplicationRecord
  belongs_to :activity, :class_name => "PublicActivity::Activity"
  belongs_to :user

  default_scope { where(is_deleted: [false, nil]) }

  enum status: [:unread, :read]

  before_create { self.status = :unread }

  delegate :trackable, :to => :activity

  def comment?
    self.activity.trackable_type == 'Comment'
  end

  def task_or_discussion
    comment? ? trackable.commentable : trackable
  end
end
