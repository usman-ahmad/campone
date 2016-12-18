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
  titles = ['Praesent nec vestibulum sem', 'Phasellus fringilla sed quam et tincidunt.', 'In varius quam sed suscipit suscipit.', 'Fusce gravida nec est nec auctor.']

  factory :discussion do
    sequence(:title) { |n| titles[(n % 4)] }
    content 'Praesent vel ex bibendum, malesuada purus et, eleifend tortor. Sed ut fringilla tellus. Aenean laoreet ornare eros ut ultrices.'

    trait :with_comments do
      transient do
        commenter { posted_by }
        comments_count 1
      end

      after(:create) do |discussion, evaluator|
        create_list(:comment, evaluator.comments_count, user: evaluator.commenter, commentable: discussion)
      end
    end

    trait :with_attachments do
      transient do
        attachments_count 1
      end

      after(:create) do |discussion, evaluator|
        create_list(:attachment, evaluator.attachments_count, uploader: discussion.posted_by, attachable: discussion)
      end
    end

    # trait :private do
    #   private true
    # end
    #
    # trait :none_private do
    #   private false
    # end
    #
    # factory :private_discussion, traits: [:private]
    # factory :none_private_discussion, traits: [:none_private]
    #
    # after(:create) do |discussion, evaluator|
    #   discussion.update_attributes(user_id: evaluator.user.id)
    #   discussion.comments << create_list(:comment, 5, user: evaluator.commenter, commentable_id: discussion.id, commentable_type: discussion.class.name, commenter: evaluator.commenter)
    #   discussion.create_activity :create, owner: evaluator.user
    # end
  end
end
