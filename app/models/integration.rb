class Integration < ActiveRecord::Base
  belongs_to :project
  has_many :payloads

  validates :url, presence: true
  validates :project_id, presence: true
  validates :name, presence: true

  scope :slack_urls,   -> {where(name: 'slack').map(&:url)}
  scope :hipchat_urls, -> {where(name: 'hipchat').map(&:url)}
  scope :flowdock_urls,-> {where(name: 'flowdock').map(&:url)}

end
