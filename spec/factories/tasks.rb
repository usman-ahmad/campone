FactoryGirl.define do
  names = ['create class diagram','create domain model','create sequaqnce diagram','create system sequance diagram']
  description = ['it should be create on time','before every diagram create it','create it after SSD',' create before sequance diagram','']

  factory :task do
    sequence(:title) { |n| names[(n % names.size)]}
    sequence(:description) { |n| description[(n % description.size)]}
    project
    due_at Date.today

    transient do
      commenter 'user'
      user nil
    end

    trait :low_priority do
      priority :low
    end

    trait :medium_priority do
      priority :medium
    end

    trait :high_priority do
      priority :high
    end

    factory :low_priority_task,    traits: [:low_priority]
    factory :medium_priority_task, traits: [:medium_priority]
    factory :high_priority_task,   traits: [:high_priority]

    after(:create) do |task,  evaluator|
      task.update_attributes(user_id: evaluator.user.id)
      task.comments << create_list(:comment, 5 ,user: evaluator.commenter, commentable_id: task.id, commentable_type: task.class.name , commenter: evaluator.commenter)
      task.create_activity :create, owner: evaluator.user
    end
  end

end
