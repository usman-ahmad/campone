class Integration < ActiveRecord::Base
  belongs_to :project
  has_many :payloads

  def create_payload payload
    #Note. there is need to add Event type in payload model
    self.payloads.create(info:payload)
  end
end
