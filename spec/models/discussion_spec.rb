# == Schema Information
#
# Table name: discussions
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  private    :boolean
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:user) { create_list(:user, 3) }
  let(:project) { create(:project, owner: user.first) }

  describe 'title' do
    it 'should present' do
      expect(build(:discussion, private: false, project: project, title: nil, opener: project.owner)).to_not be_valid
    end
  end
  describe 'invite on discussion' do
    let(:discussion) { create(:discussion, private: true, project: project, opener: project.owner) }

    it 'should share with users' do
      user.each do |user|
        FactoryGirl.create(:user_discussion, user: user, discussion: discussion)
      end
      expect(discussion.users.count).to eq(3)
    end

  end

  describe '#destroy' do
    let(:camp_project_owner) { create(:user) }
    let(:camp_project) { create(:project, title: 'UK project', owner: camp_project_owner) }
    let(:discussion_with_comments) { create(:discussion, :with_comments, comments_count: 2, opener: camp_project_owner, project: camp_project) }
    let(:discussion_with_attachments) { create(:discussion, :with_attachments, attachments_count: 2, opener: camp_project_owner, project: camp_project) }
    let(:discussion_with_real_attachments) { create(:discussion, :with_attachments, attachments_count: 1, real_attachments: true, opener: camp_project_owner, project: camp_project) }
    let(:discussion_with_comments_and_attachments) { create(:discussion, :with_comments, :with_attachments, comments_count: 2, attachments_count: 3, opener: camp_project_owner, project: camp_project) }
    let(:comment_with_real_attachments) { create(:comment, :with_attachments, attachments_count: 2, real_attachments: true, user: camp_project_owner, commentable: discussion_with_comments) }

    it 'deletes discussion with comments' do
      expect do
        discussion_with_comments
      end.to change { camp_project.discussions.count }.by(1)
                 .and change { Comment.where(commentable: camp_project.discussions).count }.by(2)

      expect do
        discussion_with_comments.destroy
      end.to change { camp_project.discussions.count }.by(-1)
                 .and change { Comment.where(commentable: camp_project.discussions).count }.by(-2)
    end

    it 'deletes discussion with attachments' do
      expect do
        discussion_with_attachments
      end.to change { camp_project.discussions.count }.by(1)
                 .and change { Attachment.where(attachable: camp_project.discussions).count }.by(2)

      expect do
        discussion_with_attachments.destroy
      end.to change { camp_project.discussions.count }.by(-1)
                 .and change { Attachment.where(attachable: camp_project.discussions).count }.by(-2)
    end

    it 'deletes discussion with real attachments' do
      discussion_with_real_attachments
      path = discussion_with_real_attachments.attachments.first.document.path
      expect(File).to exist(path)

      discussion_with_real_attachments.destroy
      expect(File).not_to exist(path)
    end

    it 'deletes discussion having comments with attachments' do
      expect do
        comment_with_real_attachments
      end.to change { Attachment.where(attachable: discussion_with_comments.comments).count }.by(2)

      path = discussion_with_comments.comments.last.attachments.first.document.path
      expect(File).to exist(path)

      discussion_with_comments.destroy
      expect(File).not_to exist(path)
    end
  end
end
