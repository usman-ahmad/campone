# == Schema Information
#
# Table name: notifications
#
#  id          :integer          not null, primary key
#  activity_id :integer
#  user_id     :integer
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  is_deleted  :boolean
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
