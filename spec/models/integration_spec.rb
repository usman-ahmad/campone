# == Schema Information
#
# Table name: integrations
#
#  id         :integer          not null, primary key
#  project_id :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  token      :string
#  secret     :string
#  type       :string
#  title      :string
#  active     :boolean
#  secure_id  :string
#

require 'rails_helper'

RSpec.describe Integration, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
