# == Schema Information
#
# Table name: attachments
#
#  id                      :integer          not null, primary key
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  description             :text
#  attachable_id           :integer
#  attachable_type         :string
#  project_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#  title                   :string
#

FactoryGirl.define do
  factory :attachment do
    title 'My attachment title'
    description 'description of my attachment.'
    project nil

    trait :with_attachment_data do
      attachment_file_name 'test_attachment.png'
      attachment_content_type 'images/png'
      attachment_file_size 559959
      attachment_updated_at '2016-12-14 07:30:41'
    end

    trait :with_real_attachment do
      attachment File.new('spec/files/awesome_project_attachment.jpg')
    end

    trait :with_comments do
      transient do
        commenter 'user'
        comments_count 1
      end

      after(:create) do |attachment, evaluator|
        create_list(:comment, evaluator.comments_count, commenter: evaluator.commenter, commentable: attachment)
      end
    end
  end
end
