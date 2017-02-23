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
#  type           :string
#

class Payload < ApplicationRecord
  after_create :create_story,          :if => :pms?  # synchronize stories for project management system like Jira, Asana, Trello etc

  belongs_to :integration
  serialize :info
  validates :event, presence: true

  def create_story
    integration.create_story_from_payload(self)
  end

  private

  def pms?
    %w[trello asana jira].include? integration.name
  end
end
