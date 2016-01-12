class Task < ActiveRecord::Base
  include Attachable
  include PublicActivity::Common

  belongs_to :project
  belongs_to :task_group
  belongs_to :created_by, class_name: User, foreign_key: :user_id
  has_many :comments,    as: :commentable
  has_many :attachments, as: :attachable

  before_create :set_position

  enum priority: [:low, :medium, :high ]
  enum progress: [:no_progress, :in_progress, :completed ]

  validates :title, presence: true
  # Do not validate due date on edit
  validate :due_date, :if => Proc.new{ |task| task.new_record? }
  accepts_nested_attributes_for :task_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  def due_date
    errors.add(:due_at, "can't be in the past") if
        due_at < Date.today if due_at.present?
  end

  def assigned_to_me(current_user)
    if (!assigned_to.present? || assigned_to.eql?(0)) && (progress.eql?("no_progress"))
      if update_attributes(assigned_to: current_user.id)
         'Task assigned to You' end
    else 'Task already assigned'end
  end

  def start_progress(current_user)
    if (assigned_to).eql?(current_user.id) && progress.eql?('no_progress')
      if update_attributes(progress: :in_progress)
           'Progress status of task has been updated'
      else 'Progress status of task could not change' end
    else   'Progress status of task cannot change' end
  end

  def self.search(text, include_completed=false)
    if include_completed
      all
    elsif text.present?
      where("title @@ :q or description @@ :q", q: text )
    else
      all.where.not(progress: Task.progresses['completed'])
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |task|
        csv << task.attributes.values_at(*column_names)
      end
    end
  end

  private

  def set_position
    self.position= Task.count + 1
  end
end
