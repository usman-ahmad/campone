FactoryGirl.define do
  comments = ['very nice','i dont link','it can be improve']
  factory :comment do
    sequence(:content) { |n| comments[(n % comments.size)]}
    user

    transient do
      commenter User.first
    end

    after(:create) do |comment,  evaluator|
     comment.create_activity :create, owner: evaluator.commenter

    end
  end
end
