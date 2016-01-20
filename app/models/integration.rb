class Integration < ActiveRecord::Base
  belongs_to :project
  has_many :payloads

  validates :url, presence: true
  validates :project_id, presence: true
  validates :vcs_name, presence: true
end
