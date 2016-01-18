class Integration < ActiveRecord::Base
  belongs_to :project
  has_many :payloads
end
