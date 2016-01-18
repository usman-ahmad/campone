class Payload < ActiveRecord::Base
  belongs_to :integration
  serialize :info
end
