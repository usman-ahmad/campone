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

  default_scope { where(hidden: [false, nil]) }

  scope :unread, -> { where(read: false) }

  # utility method that returns action like 'Created Story'
  # For now combining action with type, we can customize it i-e instead of 'Created Comment' return 'commented'
  def resource_action
    [action, resource_type].join(' ')
  end

  def comment?
    self.notifiable_type == 'Comment'
  end

  def send_faye_notifications
    message = [performer_name, resource_action, text].join(' ')

    begin
      PrivatePub.publish_to('/messages/private/user'+ receiver.to_s, message: message)
    rescue => ex
      logger.error ex.message
    end
  end

end
