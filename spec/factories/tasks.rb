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
#  progress    :string           default("unscheduled")
#  assigned_to :integer
#  user_id     :integer
#  position    :integer
#  ticket_id   :string
#

FactoryGirl.define do
  names = ['create class diagram', 'create domain model', 'create sequence diagram', 'create system sequence diagram']
  description = ['it should be create on time', 'before every diagram create it', 'create it after SSD', ' create before sequence diagram', '']

  factory :task do
    sequence(:title) { |n| names[(n % names.size)] }
    sequence(:description) { |n| description[(n % description.size)] }
    project
    due_at Date.today
    progress 'unstarted'

    # UA[2016/12/07] - TODO - RE_EVALUATE ALL FACTORIES
    # UA[2016/12/07] - REMOVE COMMENTER AND CREATOR IF NOT USED PROPERLY
    transient do
      commenter { project.owner }
      creator nil
    end

    # UA[2016/12/07] - DO WE REALLY CARE ABOUT PRIORITY IN TASK SPECS
    trait :low_priority do
      priority 'Low'
    end

    trait :medium_priority do
      priority 'Medium'
    end

    trait :high_priority do
      priority 'High'
    end

    # UA[2016/12/07] - syntax from https://github.com/thoughtbot/factory_girl/issues/527
    # will be called as - FactoryGirl.create(:task, :with_comments, comments_count: 3, commenter: someone)
    trait :with_comments do
      transient do
        commenter { owner }
        comments_count 1
      end

      after(:create) do |task, evaluator|
        create_list(:comment, evaluator.comments_count, user: evaluator.commenter, commentable: task)
      end
    end

    # after(:create) do |task, evaluator|
    #   task.update_attributes(creator: evaluator.creator)
    #   task.comments << create_list(:comment, 5, user: evaluator.commenter, commentable_id: task.id, commentable_type: task.class.name, commenter: evaluator.commenter)
    #   task.create_activity :create, owner: evaluator.creator
    # end
  end

end
