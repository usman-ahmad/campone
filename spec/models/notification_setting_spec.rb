# == Schema Information
#
# Table name: notification_settings
#
#  id               :integer          not null, primary key
#  new_story        :boolean
#  ownership_change :boolean
#  story_state      :string
#  comments         :string
#  commits          :string
#  enable           :boolean
#  type             :string
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe NotificationSetting, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end