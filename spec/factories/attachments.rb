# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :integer
#  document_updated_at   :datetime
#  description           :text
#  attachable_id         :integer
#  attachable_type       :string
#  project_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  uploader_id           :integer
#  title                 :string
#  type                  :string
#

FactoryGirl.define do
  factory :attachment do
    performer { uploader }
    trait :with_attachment_data do
      document_file_name 'no_file_here.png'
      document_content_type 'images/png'
      document_file_size 1
      document_updated_at '2001-01-01 00:00:00'
    end

    trait :with_real_attachment do
      document File.new('spec/files/awesome_project_attachment.jpg')
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
