# == Schema Information
#
# Table name: payloads
#
#  id             :integer          not null, primary key
#  info           :text
#  integration_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  event          :string
#  type           :string
#

require 'rails_helper'

RSpec.describe Payload, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
