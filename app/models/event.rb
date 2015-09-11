class Event < ActiveRecord::Base
  belongs_to :project

  validates :title, :due_at, presence: true
end
