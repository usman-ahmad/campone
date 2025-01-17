# == Schema Information
#
# Table name: contributions
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token      :string
#  status     :string           default("pending")
#  inviter_id :integer
#  position   :integer
#  initials   :string
#

FactoryGirl.define do
  factory :contribution do
    project
    user
    role 'Member'

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
