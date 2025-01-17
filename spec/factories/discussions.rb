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
#  opener_id  :integer
#

FactoryGirl.define do
  titles = ['Praesent nec vestibulum sem', 'Phasellus fringilla sed quam et tincidunt.', 'In varius quam sed suscipit suscipit.', 'Fusce gravida nec est nec auctor.']

  factory :discussion do
    sequence(:title) { |n| titles[(n % 4)] }
    content 'Praesent vel ex bibendum, malesuada purus et, eleifend tortor. Sed ut fringilla tellus. Aenean laoreet ornare eros ut ultrices.'
    performer { opener }

    trait :with_comments do
      transient do
        commenter { opener }
        comments_count 1
      end

      after(:create) do |discussion, evaluator|
        create_list(:comment, evaluator.comments_count, user: evaluator.commenter, commentable: discussion)
      end
    end

    trait :with_attachments do
      transient do
        attachments_count 1
        real_attachments false
      end

      after(:create) do |discussion, evaluator|
        if evaluator.real_attachments
          create_list(:attachment, evaluator.attachments_count, :with_real_attachment, uploader: discussion.opener, attachable: discussion)
        else
          create_list(:attachment, evaluator.attachments_count, :with_attachment_data, uploader: discussion.opener, attachable: discussion)
        end
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
