# == Schema Information
#
# Table name: discussions
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  private    :boolean
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

FactoryGirl.define do
  titles = ['intelligent features','mokups','client requirments','task deadlines']
  factory :discussion do
    sequence(:title) { |n| titles[(n % titles.size)]}
    content "client should be setisfy and project should be created on timeline"
    project

    transient do
      commenter 'user'
      user nil
    end

    trait :private do
      private true
    end

    trait :none_private do
      private false
    end

    factory :private_discussion, traits: [:private]
    factory :none_private_discussion, traits: [:none_private]

    after(:create) do |discussion,  evaluator|
      discussion.update_attributes(user_id: evaluator.user.id)
      discussion.comments << create_list(:comment, 5 ,user: evaluator.commenter, commentable_id: discussion.id, commentable_type: discussion.class.name , commenter: evaluator.commenter)
      discussion.create_activity :create, owner: evaluator.user
    end
  end



end
