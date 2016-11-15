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

  PROGRESS_MAP = {
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

  PROGRESSES = %w[unscheduled unstarted started paused finished delivered rejected accepted]
  delegate :unscheduled?, :unstarted?, :started?, :paused?, :finished?, :delivered?, :rejected?, :accepted?,
           to: :current_state
  COMPLETED_PROGRESSES = %w[finished delivered accepted]
  NOT_COMPLETED_PROGRESSES = %w[unscheduled unstarted started paused rejected]

  validates :title, presence: true
  validates :project, presence: true

  validates_inclusion_of :progress, in: PROGRESSES
  validates_inclusion_of :priority, in: PRIORITIES.values

  scope :completed, -> { where(progress: COMPLETED_PROGRESSES) }
  scope :not_completed, -> { where(progress: NOT_COMPLETED_PROGRESSES) }

  # TODO: Delete this code, We are not validating due_date, as it will cause issue while updating old task and importing tasks from third party
  def due_date
    errors.add(:due_at, "can't be in the past") if
        due_at < Date.today if due_at.present?
  end

  # def not_completed?
  #   !completed?
  # end
  def completed?
    COMPLETED_PROGRESSES.include?(self.progress)
  end

  def current_state
    progress.inquiry
  end

  # :to_do => :unscheduled, :unstarted
  # :doing => :started, :paused, :rejected
  # :done => :finished, :delivered, :accepted

  def next_states
    case progress
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

  # TODO: Refactor this method. Right now it wont assign task if it is already assigned to another user.
  # UA[2016/11/14] - TODO - REFACTOR THIS CREEPY METHOD - (BTW) WHAT IS IT DOING
  def assigned_to_me(current_user)
    if (!assigned_to.present? || assigned_to.eql?(0)) && (progress.eql?('unstarted'))
      if update_attributes(assigned_to: current_user.id)
        'Task assigned to You'
      end
    else
      'Task already assigned'
    end
  end

  # To improve user experience if a user starts progress should't we assign task to him automatically, like pivotal
  def set_progress(current_user, progress)
    if (assigned_to).eql?(current_user.id)
      if update_attributes(progress: progress)
      else
        'status of task could not change'
      end
    else
      'Task is not assigned to you'
    end
  end

  def self.filter_tasks(search_text: nil, include_completed: false)
    if include_completed
      search_text.nil? ? all : all.search(search_text)
    else
      search_text.nil? ? not_completed : not_completed.search(search_text)
    end
  end

  def self.search(text)
    where("title @@ :q or description @@ :q", q: text)
  end

  def self.to_csv(options = {})
    csv_headers = ['title', 'description', 'priority', 'progress', 'due_at']

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
