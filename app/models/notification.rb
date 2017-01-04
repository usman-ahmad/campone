# == Schema Information
#
# Table name: notifications
#
#  id          :integer          not null, primary key
#  activity_id :integer
#  user_id     :integer
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_deleted  :boolean
#

# TODO: Rename to UserNotification
class Notification < ApplicationRecord
  belongs_to :activity, :class_name => "PublicActivity::Activity"
  belongs_to :user

  default_scope { where(is_deleted: [false, nil]) }

  validates :receiver, presence: true

  # To create shortcut methods like notification.performer_name instead of notification.content['performer_name']
  store_accessor :content, [:performer_name, :text, :action, :resource_id, :resource_type, :resource_fid, :resource_link, :project_fid]

  before_create { self.status = :unread }

  delegate :trackable, :to => :activity

  def comment?
    self.activity.trackable_type == 'Comment'
  end

  def task_or_discussion
    comment? ? trackable.commentable : trackable
  end
end
