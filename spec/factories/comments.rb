# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  commentable_id   :integer
#  commentable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#

FactoryGirl.define do
  comments = ['very nice','i dont link','it can be improve']
  factory :comment do
    sequence(:content) { |n| comments[(n % comments.size)]}
    user

    transient do
      commenter 'user'
    end

    after(:create) do |comment,  evaluator|
     comment.create_activity :create, owner: evaluator.commenter

    end
  end
end
