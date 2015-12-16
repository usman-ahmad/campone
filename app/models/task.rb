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

  validates :title, :due_at, presence: true
  accepts_nested_attributes_for :task_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  def self.search(text)
    if text
      where("title @@ :q or description @@ :q", q: text )
    else
      all
    end
  end
end
