# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string
#  description       :text
#  owner_id          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  slug              :string
#  current_ticket_id :integer          default(1)
#

class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  # Now we can remove owner from project, as we have added owner role in Contribution, see #add_owner_to_contributors
  belongs_to :owner, class_name: 'User'

  has_many :contributions
  has_many :members, through: :contributions, :source => :user

  has_many :tasks
  has_many :discussions
  has_many :events
  has_many :attachments, as: :attachable, class_name: 'ProjectAttachment'

  has_many :integrations
  has_many :payloads, through: :integrations

  validates :title, presence: true
  validates :owner, presence: true

  after_create :add_owner_to_contributors

  delegate :url_helpers, to: 'Rails.application.routes'
  alias :h :url_helpers

  # TODO: Refactor and simplify
  # UA[2016/12/06] - SHOULDN'T WE USE TRANSACTIONS ???
  def create_attachments(attachments, uploaded_by)
    return if attachments.blank?

    attachments.each do |attachment|
      self.attachments.create(document: attachment, title: attachment.original_filename, uploader: uploaded_by, project_id: self.id)
    end
  end

  def json_events_for_calender
    all_events = []

    tasks.each do |task|
      all_events << {
        :id      => task.id,
        :title   => "#{ task.title }",
        :start   => "#{ task.due_at }",
        :editUrl => "#{ h.edit_project_task_path task.project, task }"
      }
    end

    events.each do |event|
      all_events << {
        :id          => event.id,
        :title       => "#{ event.title }",
        :description => "#{ event.description }",
        :start       => "#{ event.due_at }",
        :editUrl     => "#{ h.edit_project_event_path event.project, event }"
      }
    end

    return all_events.to_json
  end

  private

  def add_owner_to_contributors
    self.contributions.create(user: self.owner, status: 'joined', role: Contribution::ROLES[:owner])
  end

  # Try to create a slug with initials of project name, if its already taken try next combination of initials and random characters
  def slug_candidates
    name_initials = self.title.split.map(&:first).join if self.title

    # TODO: Try SecureRandom
    # generate a random string of length 3
    random_chars = (0...3).map { ('a'..'z').to_a[rand(26)] }.join

    [
        name_initials,
        [name_initials, random_chars]
    ]
  end
end
