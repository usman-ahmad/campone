FactoryGirl.define do
  titles = ['intelligent features','mokups','client requirments','task deadlines']
  factory :discussion do
    sequence(:title) { |n| titles[(n % titles.size)]}
    content "client should be setisfy and project should be created on timeline"
    association :discussion_group, factory: :discussion_group
    project

  trait :private do
    private true
  end

  trait :none_private do
    private false
  end

  factory :private_discussion, traits: [:private]
  factory :none_private_discussion, traits: [:none_private]

  after(:create) do |discussion|
    discussion.comments << create(:comment)
  end
  end



end
