class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :project_group

  has_many :tasks
  has_many :discussions
  has_many :invitations
  has_many :members, through: :invitations, :source => :user
  has_many :events
  has_many :attachments

  validates :name, presence: true

  accepts_nested_attributes_for :project_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  delegate :url_helpers, to: "Rails.application.routes"
  alias :h :url_helpers

  def create_attachments(array,attachment,user_id)
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
end
