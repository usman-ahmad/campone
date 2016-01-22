class Payload < ActiveRecord::Base
  after_create :send_notification
  after_create :perform_transitions

  belongs_to :integration
  serialize :info
  validates :event, presence: true

  def send_notification
    #This will send notifications to Users of this project, On which payload is created
    NotificationService.new.send_notification(message[:head],project_user)
  end

  def message
    # This will generate short message to send
    vcs_parser.message
  end

  def vcs_parser
    VCSFactory.new(self).get_vcs
  end

  def project_user
    integration.project.members
  end

  def perform_transitions
    vcs_parser.push_actions
  end
end
