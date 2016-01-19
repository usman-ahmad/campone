class Payload < ActiveRecord::Base
  belongs_to :integration
  serialize :info
  after_create :send_notification
  validates :event, presence: true

  def send_notification
  #This will send notifications to Users of this project, On which payload is created
  end

  def commit_message
  # This will generate commit _message
  end

  def project_user
  #This function will send array of users of the project
  end
end
