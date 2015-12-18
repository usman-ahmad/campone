FactoryGirl.define do
  factory :contribution do
    project
    user

    trait :organizer do
      role :organizer
      end

    trait :team_player do
      role :team_player
    end

    trait :contributor do
      role :contributor
    end

    factory :organizer_contribution,   traits: [:organizer]
    factory :team_player_contribution, traits: [:team_player]
    factory :contributor_contribution, traits: [:contributor]
  end

end
