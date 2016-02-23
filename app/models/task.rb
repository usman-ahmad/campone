class Task < ActiveRecord::Base
  include Attachable
  include PublicActivity::Common

  extend FriendlyId
  friendly_id :current_ticket_id, use: [:slugged,:finders], slug_column: :ticket_id

  belongs_to :project
  belongs_to :task_group
  belongs_to :created_by, class_name: User, foreign_key: :user_id
  has_many :comments,    as: :commentable
  has_many :attachments, as: :attachable

  before_create :set_position
  after_create  :increment_ticket_counter

  PRIORITIES = %w[None Low Medium High]
  # if you changed the order of any value of PROGRESSES array than it will reflect in lib/state.rb file.
  # So dont change order
  PROGRESSES = ['No progress', 'Started', 'In progress', 'Completed', 'Rejected', 'Accepted', 'Deployed','Closed']

  validates :title,   presence: true
  validates :project, presence: true

  validates :progress, inclusion: { in: PROGRESSES }
  validates :priority, inclusion: { in: PRIORITIES }

  accepts_nested_attributes_for :task_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  scope :not_completed, -> { where.not(progress: 'Completed') }

  # TODO: Delete this code, We are not validating due_date, as it will cause issue while updating old task and importing tasks from third party
  def due_date
    errors.add(:due_at, "can't be in the past") if
        due_at < Date.today if due_at.present?
  end

  def next_states
    State::STATE_MACHINE[progress.tr(' ', '_').downcase.to_sym]
  end

  def assigned_to_me(current_user)
    if (!assigned_to.present? || assigned_to.eql?(0)) && (progress.eql?(PROGRESSES.first))
      if update_attributes(assigned_to: current_user.id)
         'Task assigned to You' end
    else 'Task already assigned'end
  end

  def set_progress(current_user, progress)
    if (assigned_to).eql?(current_user.id)
      if update_attributes(progress: progress)
      else 'status of task could not change' end
    else   'Task is not assigned to you' end
  end

  def self.search(text, include_completed=false)
    if include_completed
      all
    elsif text.present?
      where("title @@ :q or description @@ :q", q: text )
    else
      all.not_completed
    end
  end

  def self.to_csv(options = {})
    csv_headers = ['title', 'description', 'priority','progress', 'due_at', 'group']

    CSV.generate(options) do |csv|
      csv << csv_headers
      all.each do |task|
        attributes = task.attributes
        attributes['group'] = task.task_group
        csv << attributes.values_at(*csv_headers)
      end
    end
  end

  def self.import(file, project, current_user)
    # TODO: Make it atomic
    CSV.foreach(file.path, headers: true) do |row|
      attributes  = row.to_hash
      attributes['user_id'] = current_user

      group = attributes.delete('group')
      attributes['task_group_id'] = TaskGroup.list_for(project).case_insensitive('name', group).
          first_or_create(name: group, project: project, creator: current_user).id if group

      project.tasks.create!(attributes)
    end
  end

  private

  def set_position
    self.position= Task.count + 1
  end

  def current_ticket_id
    [[project.friendly_id, project.reload.current_ticket_id]] if project
  end

  def increment_ticket_counter
    Project.increment_counter(:current_ticket_id, project)
  end
end
