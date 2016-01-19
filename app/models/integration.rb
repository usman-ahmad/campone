class Integration < ActiveRecord::Base
  belongs_to :project
  has_many :payloads

  validates :url, presence: true
  validates :project_id, presence: true
  validates :vcs_name, presence: true
  # Why is this method here?? We have a Payload ActiveRecord
  def create_payload payload
    #Note. there is need to add Event type in payload model
    self.payloads.create(info:payload)
  end
end
