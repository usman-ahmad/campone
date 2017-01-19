# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string
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
    sequence(:title) { |n| titles[(n % 5)] }
    description 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
    association :owner, factory: :user

    transient do
      member_users []
    end

    trait :with_stories do
      transient do
        story_owner { owner }
        story_count 3
      end

      after(:create) do |project, evaluator|
        create_list(:story, evaluator.story_count, project: project, requester: evaluator.story_owner)
      end
    end

    trait :with_discussions do
      transient do
        discussion_owner { owner }
        discussion_count 3
      end

      after(:create) do |project, evaluator|
        create_list(:discussion, evaluator.discussion_count, project: project, opener: evaluator.discussion_owner)
      end
    end

    trait :with_attachments do
      transient do
        attachments_count 3
        real_attachments false
      end

      after(:create) do |project, evaluator|
        if evaluator.real_attachments
          create_list(:project_attachment, evaluator.attachments_count, :with_real_attachment, uploader: project.owner, attachable: project)
        else
          create_list(:project_attachment, evaluator.attachments_count, :with_attachment_data, uploader: project.owner, attachable: project)
        end
      end
    end


    after(:create) do |project, evaluator|
      evaluator.member_users.each do |user|
        create(:contribution, project: project, user: user, role: 'Member')
      end
    end

  end
end
