FactoryGirl.define do
  factory :user do
    name "Ateek"
    sequence(:email) { |n| "teknuk#{n}@ruby.com"}
    password "secretpassword"
    password_confirmation "secretpassword"
  end
end
