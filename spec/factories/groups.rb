FactoryGirl.define do
  discussiongroup_names = ['development','analysis','diagrams','info']
  projectgroup_names = ['2015','2016','2017','2018','2019','2020']
  attachmentgroup_names = ['user interface','developer helping']
  taskgroup_names = ['front end','back end']

  factory :discussion_group do
    type 'DiscussionGroup'
    sequence(:name) { |n| discussiongroup_names[(n % discussiongroup_names.size)]}
  end

  factory :project_group do
    type 'ProjectGroup'
    sequence(:name) { |n| projectgroup_names[(n % projectgroup_names.size)]}
  end

  factory :attachment_group do
    type 'AttachmentGroup'
    sequence(:name) { |n| attachmentgroup_names[(n % attachmentgroup_names.size)]}
  end

  factory :task_group do
    type 'TaskGroup'
    sequence(:name) { |n| taskgroup_names[(n % taskgroup_names.size)]}
  end

end
