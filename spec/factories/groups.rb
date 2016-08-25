FactoryGirl.define do
  discussiongroup_names = ['development','analysis','diagrams','info']
  attachmentgroup_names = ['user interface','developer helping']
  taskgroup_names = ['front end','back end']

  factory :discussion_group do
    type 'DiscussionGroup'
    sequence(:name) { |n| discussiongroup_names[(n % discussiongroup_names.size)]}
  end

  factory :attachment_group do
    type 'AttachmentGroup'
    sequence(:name) { |n| attachmentgroup_names[(n % attachmentgroup_names.size)]}
  end

end
