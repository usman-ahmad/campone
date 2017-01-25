# == Schema Information
#
# Table name: stories
#
#  id           :integer          not null, primary key
#  title        :string
#  description  :text
#  project_id   :integer
#  priority     :string
#  due_at       :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  state        :string           default("unscheduled")
#  owner_id     :integer
#  requester_id :integer
#  position     :integer
#  ticket_id    :string
#  story_type   :string           default("feature")
#  requester_name :string
#

# UA[2016/12/18] - lorem_ipsum_ize the tests - http://www.lipsum.com/ -> 'Why do we use it?'

FactoryGirl.define do
  titles = ['lorem ipsum dolor sit amet', 'consectetur adipiscing elit', 'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', 'Ut enim ad minim veniam', 'Excepteur sint occaecat cupidatat non proident']
  states = %w[unscheduled unstarted started paused finished delivered rejected accepted]

  factory :story do
    sequence(:title) { |n| "Story #{n} is #{titles[(n % 5)]}" }
    description 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    due_at Date.today
    sequence(:state) { |n| states[(n % 8)] }
    performer { requester }

    trait :with_comments do
      transient do
        commenter { requester }
        comments_count 1
      end

      after(:create) do |story, evaluator|
        create_list(:comment, evaluator.comments_count, user: evaluator.commenter, commentable: story)
      end
    end

    trait :with_attachments do
      transient do
        attachments_count 1
        real_attachments false
      end

      after(:create) do |story, evaluator|
        if evaluator.real_attachments
          create_list(:attachment, evaluator.attachments_count, :with_real_attachment, uploader: story.requester, attachable: story)
        else
          create_list(:attachment, evaluator.attachments_count, :with_attachment_data, uploader: story.requester, attachable: story)
        end
      end
    end

    # after(:create) do |story, evaluator|
    #   story.update_attributes(requester: evaluator.requester)
    #   story.comments << create_list(:comment, 5, user: evaluator.commenter, commentable_id: story.id, commentable_type: story.class.name, commenter: evaluator.commenter)
    #   story.create_activity :create, owner: evaluator.requester
    # end
  end
end
