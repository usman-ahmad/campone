FactoryGirl.define do
  factory :contribution do
    project
    user

    trait :organizer do
      role 'Organizer'
      end

    trait :team_player do
      role 'Team player'
    end

    trait :contributor do
      role 'Contributor'
    end

    factory :organizer_contribution,   traits: [:organizer]
    factory :team_player_contribution, traits: [:team_player]
    factory :contributor_contribution, traits: [:contributor]
  end

end
