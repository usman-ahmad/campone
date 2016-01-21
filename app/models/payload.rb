require 'notification_service'
require 'message_services'
require 'github_message_service'

class Payload < ActiveRecord::Base
  after_create :send_notification
  after_create :perform_actions

  belongs_to :integration
  serialize :info
  validates :event, presence: true

  def send_notification
    #This will send notifications to Users of this project, On which payload is created
    Notification_sender.new.send_notification(message[:head],project_user)
  end

  def message
    # This will generate short message to send
    vcs_parser.message
  end

  def vcs_parser
    Vcsmessage.new(info, event, integration.vcs_name)
  end

  def project_user
    integration.project.members
  end

  def perform_actions
    vcs_parser.push_actions
  end
end
