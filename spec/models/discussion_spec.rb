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
#  opener_id  :integer
#

require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:user) { create_list(:user, 3) }
  let(:project) { create(:project, owner: user.first) }

  context 'validations' do
    it { should validate_presence_of(:title) }
  end

  context 'associations' do
    it { should have_many(:users) }
    it { should belong_to(:opener) }
    it { should belong_to(:project) }
    it { should have_many(:comments) }
    it { should have_many(:attachments) }
    it { should have_many(:user_discussions) }
  end

  # UA[2016/12/31] - TODO - WRITE PROPER SPECS
  # describe 'invite on discussion' do
  #   let(:discussion) { create(:discussion, private: true, project: project, opener: project.owner) }
  #
  #   it 'should share with users' do
  #     user.each do |user|
  #       FactoryGirl.create(:user_discussion, user: user, discussion: discussion)
  #     end
  #     expect(discussion.users.count).to eq(3)
  #   end
  # end

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

  describe 'notifications' do

    let(:opener) { create(:user, name: 'Opener name') }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, owner: opener, title: 'T E S Ting', member_users: [other_user]) }

    it { is_expected.to be_a Notifiable }
    it { is_expected.to respond_to :create_user_notifications }

    describe 'notifiable configurations' do
      let(:config) { Discussion.notifiable_config }

      it 'assigns correct values' do
        expect(config[:notifiable_attributes]).to include('title', 'content', 'private')
        expect(config[:performer]).to eq :performer
        expect(config[:receivers]).to eq :notification_receivers
        expect(config[:content_method]).to eq :title
      end
    end

    describe '#notification_receivers' do
      let(:discussion) { build(:discussion, opener: opener, project: project) }

      context 'opener is performer' do
        before do
          discussion.performer = opener
        end

        it 'notifies other user' do
          expect(discussion.send(:notification_receivers).count).to eq(1)
          expect(discussion.send(:notification_receivers)).to include(other_user)
        end
      end

      context 'other user is performer' do
        before do
          discussion.performer = other_user
        end
        it 'notifies opener user' do
          expect(discussion.send(:notification_receivers).count).to eq(1)
          expect(discussion.send(:notification_receivers)).to include(opener)
        end
      end
    end

    context 'on create' do
      let(:discussion) { build(:discussion, opener: opener, project: project, id: 1001, title: 'Discussion for testing notifications', performer: opener) }

      it 'creates notifications' do
        expect { discussion.save }.to change(Notification, :count).by(1)

        notification = other_user.notifications.last

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Opener name'
        expect(notification.notifiable).to eq discussion

        expect(notification.text).to eq 'Discussion for testing notifications'
        expect(notification.action).to eq 'Created'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Discussion'
        expect(notification.resource_fid).to eq nil
        expect(notification.resource_link).to eq '/projects/test/discussions/1001'
        expect(notification.project_fid).to eq 'test'
      end
    end


    context 'on update' do
      let!(:discussion) { create(:discussion, project: project, title: 'Discussion for testing notifications', id: 1001, performer: opener) }

      it 'creates notifications' do
        expect { discussion.update_attributes(title: 'My updated Discussion') }.to change(Notification, :count).by(1)

        notification = other_user.notifications.last

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Opener name'
        expect(notification.notifiable).to eq discussion

        expect(notification.text).to eq 'My updated Discussion'
        expect(notification.action).to eq 'Updated'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Discussion'
        expect(notification.resource_fid).to eq nil
        expect(notification.resource_link).to eq '/projects/test/discussions/1001'
        expect(notification.project_fid).to eq 'test'
      end
    end

    context 'on destroy' do
      let!(:discussion) { create(:discussion, project: project, title: 'Discussion for testing notifications', id: 1001, performer: opener) }

      it 'creates notifications' do
        expect { discussion.destroy }.to change(Notification, :count).by(1)

        notification = other_user.notifications.last

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Opener name'
        expect(notification.notifiable).to eq nil # as notifiable is deleted

        expect(notification.text).to eq 'Discussion for testing notifications'
        expect(notification.action).to eq 'Deleted'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Discussion'
        expect(notification.resource_fid).to eq nil
        expect(notification.resource_link).to eq '/projects/test/discussions/1001'
        expect(notification.project_fid).to eq 'test'
      end
    end

  end
end
