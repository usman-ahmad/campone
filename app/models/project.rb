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
  friendly_id :title_initials, use: [:slugged, :finders]

  acts_as_tagger
  # Now we can remove owner from project, as we have added owner role in Contribution, see #add_owner_to_contributors
  belongs_to :owner, class_name: 'User'

  # deleting a project will delete its stories, discussions and attachments (including comments, attachments)
  # which can break notifications
  # TODO: Fix notifications making them flat
  # TODO: Update deleting mechanism (Ask for project name)
  has_many :contributions, dependent: :destroy
  has_many :members, through: :contributions, :source => :user

  has_many :stories, dependent: :destroy
  has_many :discussions, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :attachments, as: :attachable, class_name: 'ProjectAttachment', dependent: :destroy

  has_many :integrations, dependent: :destroy
  has_many :payloads, through: :integrations

  validates :title, presence: true
  validates :owner, presence: true

  after_create :add_owner_to_contributors

  delegate :url_helpers, to: 'Rails.application.routes'
  alias :h :url_helpers

  def joined_members
    members.merge(Contribution.joined)
  end

  # TODO: Refactor and simplify
  # UA[2016/12/06] - SHOULDN'T WE USE TRANSACTIONS ???
  def create_attachments(attachments, uploaded_by)
    return if attachments.blank?

    attachments.each do |attachment|
      self.attachments.create(document: attachment, title: attachment.original_filename, performer: uploaded_by, project_id: self.id)
    end
  end

  def json_events_for_calender
    all_events = []

    stories.each do |story|
      all_events << {
        :id      => story.id,
        :title   => "#{ story.title }",
        :start   => "#{ story.due_at }",
        :editUrl => "#{ h.edit_project_story_path story.project, story }"
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

  def normalize_friendly_id(initials)
    postfix = initials.length.equal?(1) ? 1 : ''
    while Project.exists?(slug: "#{initials}#{postfix}") do
      postfix = (postfix || 0) + 1
    end
    "#{initials}#{postfix}"
  end

  private

  def add_owner_to_contributors
    position = self.owner.projects.maximum(:position) ? self.owner.projects.maximum(:position) + 1 : 1
    self.contributions.create(user: self.owner, status: 'joined', role: Contribution::ROLES[:owner], position: position)
  end

  def title_initials
    (self.title || 'p r o').split.map(&:first).join.downcase
  end
end
