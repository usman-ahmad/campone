class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged,:finders]

  belongs_to :owner, class_name: 'User'
  belongs_to :project_group

  has_many :tasks
  has_many :discussions
  has_many :contributions
  has_many :members, through: :contributions, :source => :user
  has_many :events
  has_many :attachments

  validates :name, presence: true
  validates :owner, presence: true

  accepts_nested_attributes_for :project_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  after_create :add_owner_to_contributors

  delegate :url_helpers, to: "Rails.application.routes"
  alias :h :url_helpers

  # TODO: Refactor and simplify
  def create_attachments(array,attachment)
    return unless array.present?
    group = AttachmentGroup.where(id:attachment[:attachment_group_id]).first
    if !group.present?
      group = nil
      group = AttachmentGroup.create(name:attachment[:attachment_group_attributes][:name]) if attachment[:attachment_group_attributes][:name].present?
    end
    array.each do |file|
     attachments.build(:attachment => file, attachment_group: group, user_id: user_id )
      # current_attachment.attachments.build(attachment)
    end

    save
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

=begin
  TODO:
  Now we can remove owner from project, as we have added owner role in Contribution
=end
  def add_owner_to_contributors
    self.contributions.create(user: self.owner, role: 'owner')
  end

  # Try to create a slug with initials of project name, if its already taken try next combination of initials and random characters
  def slug_candidates
    name_initials = self.name.split.map(&:first).join

    # TODO: Try SecureRandom
    # generate a random string of length 3
    random_chars  = (0...3).map { ('a'..'z').to_a[rand(26)] }.join

    [
        name_initials,
        [name_initials, random_chars]
    ]
  end
end
