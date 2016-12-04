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
  names = ['desktop medical store MIS', 'online medical store MIS', 'mobile app of MIS', 'face recognition', 'time tracking']
  description = ['it should be created on .net', 'it should be created on ROR', 'it should be created on android', 'this can be create on any language', 'it should be created on php']

  factory :project do
    sequence(:name) { |n| names[(n % names.size)] }
    sequence(:description) { |n| description[(n % description.size)] }
    association :owner, factory: :user
  end

  factory :project_with_single_task, parent: :project do
    after(:create) do |project|
      create(:task, :low_priority, project: project, commenter: project.owner, creator: project.owner)
    end
  end

  factory :project_with_many_tasks, parent: :project do
    after(:create) do |project|
      create(:task, :low_priority, project: project, commenter: project.owner, creator: project.owner)
      create(:task, :low_priority, project: project, progress: 'finished', commenter: project.owner, creator: project.owner)
      create(:task, :medium_priority, project: project, commenter: project.owner, creator: project.owner)
      create(:task, :medium_priority, project: project, commenter: project.owner, creator: project.owner)
      create(:task, :high_priority, project: project, progress: 'unstarted', commenter: project.owner, creator: project.owner)
      create(:task, :high_priority, project: project, progress: 'started', commenter: project.owner, creator: project.owner)
    end
  end

  factory :project_with_discussions, parent: :project do
    after(:create) do |project|
      create(:none_private_discussion, project: project, commenter: project.owner, user: project.owner)
      create(:private_discussion, project: project, commenter: project.owner, user: project.owner)
    end
  end

  factory :project_with_task_discussions, parent: :project do
    after(:create) do |project|
      create(:none_private_discussion, project: project, commenter: project.owner, user: project.owner)
      create(:task, :medium_priority, project: project, commenter: project.owner, creator: project.owner)
    end
  end

end
