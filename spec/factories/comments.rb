FactoryGirl.define do
  comments = ['very nice','i dont link','it can be improve']
  factory :comment do
    sequence(:content) { |n| comments[(n % comments.size)]}
    user
  end
end
