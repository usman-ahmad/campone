FactoryGirl.define do
  factory :invitation do
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

    factory :organizer_invitation,   traits: [:organizer]
    factory :team_player_invitation, traits: [:team_player]
    factory :contributor_invitation, traits: [:contributor]
  end

end
