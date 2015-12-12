FactoryGirl.define do
  names = ['desktop medical store MIS','online medical store MIS','mobile app of MIS','face recognition','time tracking']
  description = ['it should be created on .net','it should be created on ROR','it should be created on android','this can be create on any language','it should be created on php']

  factory :project do
    sequence(:name) { |n| names[(n % names.size)]}
    sequence(:description) { |n| description[(n % description.size)]}
    association :project_group, factory: :project_group
    association :owner, factory: :user
  end

  factory :project_with_single_task, parent: :project do
    after(:create) do |project|
    create(:low_priority_task, project: project, commenter: project.owner )
    end
  end

  factory :project_with_many_tasks, parent: :project do
    after(:create) do |project|
      create(:low_priority_task,project: project, commenter: project.owner )
      create(:low_priority_task,project: project,progress: :completed, commenter: project.owner )
      create(:medium_priority_task,project: project , commenter: project.owner)
      create(:medium_priority_task,project: project , commenter: project.owner)
      create(:high_priority_task,project: project,progress: :no_progress , commenter: project.owner)
      create(:high_priority_task,project: project,progress: :in_progress , commenter: project.owner)
    end
  end

  factory :project_with_discussions, parent: :project do
    after(:create) do |project|
      create(:none_private_discussion,project: project, commenter: project.owner )
      create(:private_discussion,project: project, commenter: project.owner )
    end
  end

  factory :project_with_task_discussions, parent: :project do
    after(:create) do |project|
      create(:none_private_discussion,project: project, commenter: project.owner )
      create(:medium_priority_task,project: project , commenter: project.owner)
    end
  end

end
