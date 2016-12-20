# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  project_id  :integer
#  priority    :string           default("None")
#  due_at      :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state       :string           default("unscheduled")
#  assigned_to :integer
#  user_id     :integer
#  position    :integer
#  ticket_id   :string
#

class Task < ApplicationRecord
  include Attachable
  include PublicActivity::Common

  extend FriendlyId
  friendly_id :current_ticket_id, use: [:slugged, :finders], slug_column: :ticket_id
  alias_attribute :slug, :ticket_id

  belongs_to :project

  belongs_to :creator, class_name: User, foreign_key: :user_id
  belongs_to :owner, class_name: User, foreign_key: :assigned_to

  has_many :attachments, as: :attachable

  has_many :comments,    as: :commentable

  before_create :set_position
  after_create  :increment_ticket_counter

  PRIORITIES = {
      NONE:   'None',
      LOW:    'Low',
      MEDIUM: 'Medium',
      HIGH:   'High'
  }

  STATE_MAP = {
      NOT_SCHEDULED: 'unscheduled',
      NO_PROGRESS: 'unstarted',
      IN_PROGRESS: 'started',
      PAUSED: 'paused',
      COMPLETED: 'finished',
      DEPLOYED: 'delivered',
      REJECTED: 'rejected',
      ACCEPTED: 'accepted',
      CLOSED: 'accepted'
  }

  STATES = %w[unscheduled unstarted started paused finished delivered rejected accepted]
  delegate :unscheduled?, :unstarted?, :started?, :paused?, :finished?, :delivered?, :rejected?, :accepted?,
           to: :current_state
  CURRENT_STATES = %w[unstarted started paused finished delivered rejected]

  validates :title, presence: true
  validates :project, presence: true

  validates_inclusion_of :state, in: STATES
  validates_inclusion_of :priority, in: PRIORITIES.values

  # COMPLETED_STATES = %w[finished delivered accepted]
  # NOT_COMPLETED_STATES = %w[unscheduled unstarted started paused rejected]
  # UA[2016/11/22] - NOT USED ANY WHERE # REFACTOR SPECS
  # scope :completed, -> { where(state: COMPLETED_STATES) }
  # scope :not_completed, -> { where(state: NOT_COMPLETED_STATES) }

  # TODO: Delete this code, We are not validating due_date, as it will cause issue while updating old task and importing tasks from third party
  def due_date
    errors.add(:due_at, "can't be in the past") if
        due_at < Date.today if due_at.present?
  end

  # def not_completed?
  #   !completed?
  # end
  # UA[2016/11/22] - NOT BEING USED IN CODE
  # def completed?
  #   COMPLETED_STATES.include?(self.state)
  # end

  def current_state
    state.inquiry
  end

  # :to_do => :unscheduled, :unstarted
  # :doing => :started, :paused, :rejected
  # :done => :finished, :delivered, :accepted

  def next_states
    case state
      when 'unscheduled'
        {schedule: 'unstarted', start: 'started'}
      when 'unstarted'
        {start: 'started'}
      when 'started'
        {pause: 'paused', finish: 'finished'}
      when 'paused'
        {resume: 'started'}
      when 'finished'
        {deliver: 'delivered'}
      when 'delivered'
        {accept: 'accepted', reject: 'rejected'}
      when 'rejected'
        {restart: 'started'}
      when 'accepted'         # :accepted ~ :closed
        {}
      else
        {}
    end
  end

  def self.with_state(visibility_or_state)
    case visibility_or_state
      when 'current'
        where(state: CURRENT_STATES)
      when 'all'
        all
      else
        where(state: visibility_or_state)
    end
  end

  # UA[2016/11/28] - moved to controller with plain "update_attributes" call # REFACTOR SPECS
  # UA[2016/11/28] - assigned_to_me even if the task is started(or any other state) or assigned to anyone else
  # def assigned_to_me(current_user)
  #   # if (!assigned_to.present? || assigned_to.eql?(0)) && (state.eql?('unstarted'))
  #   #   if update_attributes(assigned_to: current_user.id)
  #   #     'Task assigned to You'
  #   #   end
  #   # else
  #   #   'Task already assigned'
  #   # end
  #   if update_attributes(assigned_to: current_user.id)
  #     'Task assigned to You'
  #   else
  #     'Task could not be assigned to You'
  #   end
  # end

  # UA[2016/11/28] - moved to controller with plain "update_attributes" call # REFACTOR SPECS
  # UA[2016/11/28] - Anyone can set tasks state (even if not owner of task)
  # # To improve user experience if a user starts state shouldn't we assign task to him automatically, like pivotal
  # def set_state(current_user, state)
  #   # if (assigned_to).eql?(current_user.id)
  #   #   if update_attributes(state: state)
  #   #   else
  #   #     'status of task could not change'
  #   #   end
  #   # else
  #   #   'Task is not assigned to you'
  #   # end
  #   if update_attributes(state: state)
  #     'State of task is updated successfully'
  #   else
  #     'State of task could not be updated'
  #   end
  # end

  # UA[2016/11/22] - NOT USED ANY WHERE # REFACTOR SPECS
  # def self.filter_tasks(search_text: nil, include_completed: false)
  #   if include_completed
  #     search_text.nil? ? all : all.search(search_text)
  #   else
  #     search_text.nil? ? not_completed : not_completed.search(search_text)
  #   end
  # end

  def self.search(text)
    if text.present?
      where('title @@ :q or description @@ :q', q: text)
    else
      all
    end
  end

  def self.to_csv(options = {})
    csv_headers = ['title', 'description', 'priority', 'state', 'due_at']

    CSV.generate(options) do |csv|
      csv << csv_headers
      all.each do |task|
        attributes = task.attributes
        csv << attributes.values_at(*csv_headers)
      end
    end
  end

  def self.import(file, project, current_user)
    # TODO: Make it atomic
    CSV.foreach(file.path, headers: true) do |row|
      attributes = row.to_hash
      attributes['user_id'] = current_user

      project.tasks.create!(attributes)
    end
  end

  private

  def set_position
    self.position = self.project.tasks.count + 1
  end

  def current_ticket_id
    [[project.friendly_id, project.reload.current_ticket_id]] if project
  end

  def increment_ticket_counter
    Project.increment_counter(:current_ticket_id, project)
  end
end
