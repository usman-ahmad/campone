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
    performer { user }
    sequence(:content) { |n| comments[(n % 3)] }

    trait :with_attachments do
      transient do
        attachments_count 1
        real_attachments false
      end

      after(:create) do |comment, evaluator|
        if evaluator.real_attachments
          create_list(:attachment, evaluator.attachments_count, :with_real_attachment, uploader: comment.user, attachable: comment)
        else
          create_list(:attachment, evaluator.attachments_count, :with_attachment_data, uploader: comment.user, attachable: comment)
        end
      end
    end

    # after(:create) do |comment, evaluator|
    #   comment.create_activity :create, owner: comment.user
    # end
  end
end
