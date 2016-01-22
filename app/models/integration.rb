class Integration < ActiveRecord::Base
  belongs_to :project
  has_many :payloads

  validates :url, presence: true
  validates :project_id, presence: true
  validates :name, presence: true
end
