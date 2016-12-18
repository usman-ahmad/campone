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
  comments = ['lorem ipsum dolor sit amet', 'lorem ipsum dolor sit amet, consectetur adipiscing elit', 'Excepteur sint occaecat cupidatat non proident']

  factory :comment do
    sequence(:content) { |n| comments[(n % 3)] }

    trait :with_attachments do
      transient do
        attachments_count 1
      end

      after(:create) do |comment, evaluator|
        create_list(:attachment, evaluator.attachments_count, uploader: comment.user, attachable: comment)
      end
    end

    # after(:create) do |comment, evaluator|
    #   comment.create_activity :create, owner: comment.user
    # end
  end
end
