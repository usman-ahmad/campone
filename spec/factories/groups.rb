FactoryGirl.define do
  attachmentgroup_names = ['user interface','developer helping']

  factory :attachment_group do
    type 'AttachmentGroup'
    sequence(:name) { |n| attachmentgroup_names[(n % attachmentgroup_names.size)]}
  end

end
