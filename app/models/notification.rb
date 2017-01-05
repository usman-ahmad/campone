# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  receiver_id     :integer
#  performer_id    :integer
#  content         :json
#  notifiable_type :string
#  notifiable_id   :integer
#  read            :boolean          default(FALSE)
#  hidden          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# TODO: Rename to UserNotification
class Notification < ApplicationRecord
  belongs_to :receiver, class_name: 'User'
  belongs_to :performer, class_name: 'User' # We can use it while updating i-e if user changes his name
  belongs_to :notifiable, polymorphic: true


  default_scope { where(hidden: [false, nil]) }

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
