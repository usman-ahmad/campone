class Task < ActiveRecord::Base
  include Attachable
  include PublicActivity::Common

  belongs_to :project
  belongs_to :task_group
  belongs_to :created_by, class_name: User, foreign_key: :user_id
  has_many :comments,    as: :commentable
  has_many :attachments, as: :attachable

  enum priority: [:low, :medium, :high ]
  enum progress: [:no_progress, :in_progress, :completed ]

  validates :title, presence: true
  accepts_nested_attributes_for :task_group, :reject_if => proc { |attributes| attributes['name'].blank? }

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
end
