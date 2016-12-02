# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  due_at      :date
#  project_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Event < ApplicationRecord
  belongs_to :project

  validates :title, :due_at, presence: true
  validate :due_date

  def due_date
    errors.add(:due_at, "can't be in the past") if
        due_at < Date.today if due_at.present?
  end
end
