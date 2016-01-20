require 'notification_service'
require 'message_services'
require 'github_message_service'

class Payload < ActiveRecord::Base
  after_create :send_notification

  belongs_to :integration
  serialize :info
  validates :event, presence: true

  def send_notification
    #This will send notifications to Users of this project, On which payload is created
    Notification_sender.new.send_notification(message,project_user)
  end

  def message
    # This will generate short message to send
    Vcsmessage.new(info, event, integration.vcs_name).message
  end

  def project_user
    integration.project.members
  end
end
