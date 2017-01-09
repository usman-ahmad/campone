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
  describe 'associations' do
    it { should belong_to(:receiver).class_name('User') }
    it { should belong_to(:performer).class_name('User') }
    it { should belong_to(:notifiable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:receiver) }
  end

end
