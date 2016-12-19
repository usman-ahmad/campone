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
#  user_id               :integer
#  title                 :string
#  type                  :string
#

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:project_attachment) { create(:project_attachment, :with_comments, comments_count: 4, commenter: user, attachable: project, document: File.new('spec/files/awesome_project_attachment.jpg')) }

  context 'associations' do
    it { should belong_to :project }
    it { should belong_to(:uploader).class_name('User').with_foreign_key('user_id') }
    it { should belong_to(:attachable) }
  end

  context 'validations - paperclip' do
    NOT_ALLOWED_CONTENT_TYPES = %w[application/x-msdownload] # exe

    it { should have_attached_file(:document) }
    it { should validate_attachment_presence(:document) }
    it { should validate_attachment_content_type(:document).rejecting(NOT_ALLOWED_CONTENT_TYPES) }
    it { should validate_attachment_size(:document).less_than(20.megabytes) }
  end

  it 'has a valid factories' do
    create(:project_attachment, document: File.new('spec/files/awesome_project_attachment.jpg'), attachable: project).should be_valid
    create(:project_attachment, :with_attachment_data, attachable: project).should be_valid
    create(:project_attachment, :with_real_attachment, attachable: project).should be_valid
    create(:project_attachment, :with_attachment_data, :with_comments, comments_count: 3, commenter: user, attachable: project).should be_valid
  end

  it 'ensures comments on attachment' do
    expect(project_attachment.comments.count).to eq(4)

    project_attachment.comments.each do |comment|
      expect(comment.commentable).to eq(project_attachment)
      expect(comment.commentable.attachable).to eq(project)
    end
  end

  context 'db' do
    context 'columns' do
      it { should have_db_column(:type).of_type(:string) }
      it { should have_db_column(:title).of_type(:string) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:document_file_name).of_type(:string) }
    end

    context 'indexes' do
      it { should have_db_index(:project_id) }
    end
  end

  it 'increment attachments count' do
    expect { create(:project_attachment, document: File.new('spec/files/awesome_project_attachment.jpg'), attachable: project) }.to change { Attachment.count }.by(1)
  end

  context '#is_image?' do
    it 'should be an image' do
      expect(project_attachment.is_image?).to be_truthy
    end

    it 'should not be image' do
      expect(project_attachment.is_video?).to be_falsey
    end
  end

  context '#project' do
    let(:task) { create(:task, title: 'task one', creator: user, project: project) }
    let(:task_attachment) { create(:attachment, attachable: task, document: File.new('spec/files/awesome_project_attachment.jpg')) }
    # let(:discussion) { create(:discussion, private: false, project: project, user: project.owner) }
    # let(:discussion_attachment) { create(:attachment, :with_attachment_data, attachable: discussion) }

    it 'should return attachment project' do
      expect(project_attachment.attachable).to eq(project)
    end

    it 'should return task attachment project' do
      expect(task_attachment.attachable.project).to eq(project)
    end
  end
end
