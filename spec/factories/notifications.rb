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
