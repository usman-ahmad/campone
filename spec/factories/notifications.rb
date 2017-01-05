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

FactoryGirl.define do
  factory :notification do

    trait :unread do
      status :unread
    end

    trait :read do
      status :read
    end

    factory :read_notification, traits: [:read]
    factory :unread_notification, traits: [:unread]
  end

end
