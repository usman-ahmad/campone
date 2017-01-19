# == Schema Information
#
# Table name: payloads
#
#  id             :integer          not null, primary key
#  info           :text
#  integration_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  event          :string
#

class Payload < ApplicationRecord
  after_create :send_notification,    :if => :vcs?
  after_create :perform_transitions,  :if => :vcs?  # Perform actions on commit for VCS system like github and Bitbucket etc
  after_create :create_story,          :if => :pms?  # synchronize stories for project management system like Jira, Asana, Trello etc

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

  def create_story
    ImportService.build(integration).create_story_from_payload(self)
  end

  private

  def vcs?
    %w[github bitbucket].include? integration.name
  end

  def pms?
    %w[trello asana jira].include? integration.name
  end
end
