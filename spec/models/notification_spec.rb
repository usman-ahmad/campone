# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  receiver_id     :integer
#  performer_id    :integer
#  content         :json
#  notifiable_type :string
#  notifiable_id   :integer
#  read            :boolean          default(FALSE)
#  hidden          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
