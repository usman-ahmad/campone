FactoryGirl.define do
  factory :contribution do
    project
    user

    trait :manager do
      role 'Manager'
    end

    trait :member do
      role 'Member'
    end

    trait :guest do
      role 'Guest'
    end

    factory :manager_contribution, traits: [:manager]
    factory :member_contribution, traits: [:member]
    factory :guest_contribution, traits: [:guest]
  end

end
