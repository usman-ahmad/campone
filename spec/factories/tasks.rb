# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  project_id  :integer
#  priority    :string           default("None")
#  due_at      :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state       :string           default("unscheduled")
#  assigned_to :integer
#  user_id     :integer
#  position    :integer
#  ticket_id   :string
#

# UA[2016/12/18] - lorem_ipsum_ize the tests - http://www.lipsum.com/ -> 'Why do we use it?'

FactoryGirl.define do
  titles = ['lorem ipsum dolor sit amet', 'consectetur adipiscing elit', 'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', 'Ut enim ad minim veniam', 'Excepteur sint occaecat cupidatat non proident']
  states = %w[unscheduled unstarted started paused finished delivered rejected accepted]

  factory :task do
    sequence(:title) { |n| "Task #{n} is #{titles[(n % 5)]}" }
    description 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    due_at Date.today
    sequence(:state) { |n| states[(n % 8)] }

    trait :with_comments do
      transient do
        commenter { owner }
        comments_count 1
      end

      after(:create) do |task, evaluator|
        create_list(:comment, evaluator.comments_count, user: evaluator.commenter, commentable: task)
      end
    end

    trait :with_attachments do
      transient do
        attachments_count 1
      end

      after(:create) do |task, evaluator|
        create_list(:attachment, evaluator.attachments_count, uploader: task.owner, attachable: task)
      end
    end

    # after(:create) do |task, evaluator|
    #   task.update_attributes(creator: evaluator.creator)
    #   task.comments << create_list(:comment, 5, user: evaluator.commenter, commentable_id: task.id, commentable_type: task.class.name, commenter: evaluator.commenter)
    #   task.create_activity :create, owner: evaluator.creator
    # end
  end
end
