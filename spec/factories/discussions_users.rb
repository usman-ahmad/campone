FactoryGirl.define do
  factory :user_discussion do
    user
    discussion
    notify false
  end

end
