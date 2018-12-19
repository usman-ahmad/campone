# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  commentable_type :string
#  commentable_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }

    it { should have_many(:attachments) }
  end

  describe '#destroy' do
    let(:camp_project_owner) { create(:user) }
    let(:camp_project) { create(:project, title: 'chat project', owner: camp_project_owner) }
    let(:story_with_comments) { create(:story, :with_comments, comments_count: 3, requester: camp_project_owner, project: camp_project) }
    let(:comment_with_real_attachments) { create(:comment, :with_attachments, attachments_count: 2, real_attachments: true, user: camp_project_owner, commentable: story_with_comments) }

    it 'deletes story having comments with attachments' do
      expect do
        comment_with_real_attachments
      end.to change { Comment.where(commentable: camp_project.stories).count }.by(1)
                 .and change { Attachment.where(attachable: story_with_comments.comments).count }.by(2)

      path = story_with_comments.comments.last.attachments.first.document.path
      expect(File).to exist(path)

      expect do
        story_with_comments.destroy
      end.to change { camp_project.stories.count }.by(-1)
                 .and change { Comment.where(commentable: camp_project.stories).count }.by(-4)
                          .and change { Attachment.where(attachable: story_with_comments.comments).count }.by(-2)

      expect(File).not_to exist(path)
    end
  end

  describe 'notifications' do
    let(:owner) { create(:user, name: 'Owner name') }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, owner: owner, title: 'T E S Ting', member_users: [other_user]) }
    let!(:story) { create(:story, project: project, id: 1001, performer: owner) }

    it { is_expected.to be_a Notifiable }

    it 'implements act_as_notifiable' do
      expect(Comment).to respond_to(:act_as_notifiable).with(1).argument
    end

    describe 'notifiable configurations' do
      let(:config) { Comment.notifiable_config }

      it 'assigns correct values' do
        expect(config[:notifiable_attributes]).to include('content')
        expect(config[:performer]).to eq :performer
        expect(config[:receivers]).to eq :notification_receivers
        expect(config[:content_method]).to eq :content
      end
    end

    context 'on create' do
      let(:comment) { build(:comment, id: 1001, user: owner, performer: owner, commentable: story, content: 'Comment for testing notifications') }

      it 'creates notifications' do
        expect { comment.save }.to change(Notification, :count).by(1)

        notification = other_user.notifications.last

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq comment

        expect(notification.text).to eq 'Comment for testing notifications'
        expect(notification.action).to eq 'Created'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Comment'
        expect(notification.resource_fid).to eq nil
        expect(notification.resource_link).to eq '/projects/test/stories/test-1'
        expect(notification.project_fid).to eq 'test'
      end
    end


    context 'on update', pending: 'scenario has been removed from comments model' do
      let(:other_user) { create(:user) }
      let!(:comment) { create(:comment, commentable: story, content: 'Comment for testing notifications', id: 1001, performer: owner) }

      it 'creates notifications' do
        expect { comment.update_attributes(content: 'My updated comment') }.to change(Notification, :count).by(1)

        notification = other_user.notifications.last

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq comment

        expect(notification.text).to eq 'My updated comment'
        expect(notification.action).to eq 'Updated'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Comment'
        expect(notification.resource_fid).to eq nil
        expect(notification.resource_link).to eq '/projects/test/stories/test-1'
        expect(notification.project_fid).to eq 'test'
      end
    end

    context 'on destroy', pending: 'scenario has been removed from comments model' do
      let(:other_user) { create(:user) }
      let!(:comment) { create(:comment, commentable: story, content: 'Comment for testing notifications', id: 1001, performer: owner) }

      it 'creates notifications' do
        expect { comment.destroy }.to change(Notification, :count).by(1)

        notification = other_user.notifications.last

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq nil # as notifiable is deleted

        expect(notification.text).to eq 'Comment for testing notifications'
        expect(notification.action).to eq 'Deleted'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Comment'
        expect(notification.resource_fid).to eq nil
        expect(notification.resource_link).to eq '/projects/test/stories/test-1'
        expect(notification.project_fid).to eq 'test'
      end
    end

  end # notifications
end
