FactoryGirl.define do
  names = ['waqas','salman','sunny','asad','irtaza']
  factory :user do
    sequence(:name) { |n| names[(n % names.size)]}
    sequence(:email) { |n| "teknuk-#{names[(n % names.size)]}@ruby.com"}
    password "secretpassword"
    password_confirmation "secretpassword"
  end
end
