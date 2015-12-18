class Event < ActiveRecord::Base
  belongs_to :project

  validates :title, :due_at, presence: true
  validate :due_date

  def due_date
    errors.add(:due_at, "can't be in the past") if
        due_at < Date.today if due_at.present?
  end
end
