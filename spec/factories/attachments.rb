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
#  type                    :string
#

FactoryGirl.define do
  factory :attachment do
    trait :with_attachment_data do
      attachment_file_name 'no_file_here.png'
      attachment_content_type 'images/png'
      attachment_file_size 1
      attachment_updated_at '2001-01-01 00:00:00'
    end

    trait :with_real_attachment do
      attachment File.new('spec/files/awesome_project_attachment.jpg')
    end
  end

  factory :project_attachment, parent: :attachment, class: 'ProjectAttachment' do
    title 'My attachment title'
    description 'Description of my attachment.'

    trait :with_comments do
      transient do
        commenter { uploader }
        comments_count 1
      end

      after(:create) do |attachment, evaluator|
        create_list(:comment, evaluator.comments_count, user: evaluator.commenter, commentable: attachment)
      end
    end
  end
end
