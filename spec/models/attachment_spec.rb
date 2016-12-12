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

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:attachment) { create(:attachment, :with_comments, comments_count: 4, commenter: user, attachable: project, attachment: File.new('spec/files/awesome_project_attachment.jpg')) }

  context 'associations' do
    it { should belong_to :project }
    it { should belong_to(:uploader).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:attachable) }
    it { should have_many(:comments) }
  end

  context 'validations - paperclip' do
    NOT_ALLOWED_CONTENT_TYPES = %w[application/x-msdownload] # exe

    it { should have_attached_file(:attachment) }
    it { should validate_attachment_presence(:attachment) }
    it { should validate_attachment_content_type(:attachment).rejecting(NOT_ALLOWED_CONTENT_TYPES) }
    it { should validate_attachment_size(:attachment).less_than(20.megabytes) }
  end

  it 'has a valid factories' do
    create(:attachment, attachment: File.new('spec/files/awesome_project_attachment.jpg'), attachable: project).should be_valid
    create(:attachment, :with_attachment_data, attachable: project).should be_valid
    create(:attachment, :with_real_attachment, attachable: project).should be_valid
    create(:attachment, :with_attachment_data, :with_comments, comments_count: 3, commenter: user, attachable: project).should be_valid
  end

  it 'ensures comments on attachment' do
    expect(attachment.comments.count).to eq(4)

    attachment.comments.each do |comment|
      expect(comment.commentable).to eq(attachment)
      expect(comment.commentable.attachable).to eq(project)
    end
  end

  context 'db' do
    context 'columns' do
      it { should have_db_column(:type).of_type(:string) }
      it { should have_db_column(:title).of_type(:string) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:attachment_file_name).of_type(:string) }
    end

    context 'indexes' do
      it { should have_db_index(:project_id) }
    end
  end

  it 'increment attachments count' do
    expect { create(:attachment, attachment: File.new('spec/files/awesome_project_attachment.jpg')) }.to change { Attachment.count }.by(1)
  end

  context '#is_image?' do
    it 'should be an image' do
      expect(attachment.is_image?).to be_truthy
    end

    it 'should not be image' do
      expect(attachment.is_video?).to be_falsey
    end
  end

  context '#project' do
    let(:task) { create(:task, title: 'task one', creator: user, project: project) }
    let(:discussion) { create(:none_private_discussion, project: project, commenter: project.owner, user: project.owner) }
    let(:task_attachment) { create(:attachment, attachable: task, attachment: File.new('spec/files/awesome_project_attachment.jpg')) }
    let(:discussion_attachment) { create(:attachment, :with_attachment_data, attachable: discussion) }

    it 'should return attachment project' do
      expect(attachment.attachable).to eq(project)
    end

    it 'should return task attachment project' do
      expect(task_attachment.attachable.project).to eq(project)
    end
  end
end
