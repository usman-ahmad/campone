FactoryGirl.define do
  names = ['desktop medical store MIS','online medical store MIS','mobile app of MIS','face recognition']
  description = ['it should be created on .net','it should be created on ROR','it should be created on android','this can be create on any language']

  factory :project do
    sequence(:name) { |n| names[(n % names.size)]}
    sequence(:description) { |n| description[(n % description.size)]}

    association :owner, factory: :user
  end

  factory :project_with_single_task, parent: :project do
    after(:create) do |project|
    create(:low_priority_task, project: project )
    end
  end

  factory :project_with__many_tasks, parent: :project do
    after(:create) do |project|
      create(:low_priority_task,project: project )
      create(:medium_priority_task,project: project )
      create(:high_priority_task,project: project )
    end
  end

end
