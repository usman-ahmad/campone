# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  name              :string
#  description       :text
#  owner_id          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  slug              :string
#  current_ticket_id :integer          default(1)
#

FactoryGirl.define do
  titles = ['Green Grass', 'Blue Sky', 'Fully Ripe Orange', 'Red Blood Cells', 'Grey Scale']

  factory :project do
    sequence(:name) { |n| titles[(n % 5)] }
    description 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    association :owner, factory: :user

    trait :with_tasks do
      transient do
        task_owner { owner }
        task_count 3
      end

      after(:create) do |project, evaluator|
        create_list(:task, evaluator.task_count, project: project, creator: evaluator.task_owner)
      end
    end

    trait :with_discussions do
      transient do
        discussion_owner { owner }
        discussion_count 3
      end

      after(:create) do |project, evaluator|
        create_list(:discussion, evaluator.discussion_count, project: project, posted_by: evaluator.discussion_owner)
      end
    end

    trait :with_attachments do
      transient do
        attachments_count 3
      end

      after(:create) do |project, evaluator|
        create_list(:project_attachment, evaluator.attachments_count, uploader: project.owner, attachable: project)
      end
    end
  end
end
