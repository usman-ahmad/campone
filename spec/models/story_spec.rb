# == Schema Information
#
# Table name: stories
#
#  id           :integer          not null, primary key
#  title        :string
#  description  :text
#  project_id   :integer
#  priority     :string
#  due_at       :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  state        :string           default("unscheduled")
#  owner_id     :integer
#  requester_id :integer
#  position     :integer
#  ticket_id    :string
#  story_type   :string           default("feature")
#

require 'rails_helper'

# Custom matcher for matching Exported CSV data with expected results
RSpec::Matchers.define :have_value do |attribute, expected|
  match do |obj|
    if obj.is_a? Hash
      obj[attribute.to_s] == expected
    else
      obj.send(attribute)
    end
  end

  description do
    "have value '#{expected}' for '#{attribute}"
  end
end


RSpec.describe Story, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user, title: 'T E S Ting') }

  context 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:story_type) }

    it { should allow_value('unscheduled', 'unstarted', 'started', 'paused', 'finished', 'delivered', 'rejected',
                            'accepted').for(:state) }
    it { should_not allow_value('none', 'blah', 'current').for(:state) }

    it { should allow_value('Low', 'Medium', 'High').for(:priority) }
    it { should_not allow_value('blah').for(:priority) }

    it { should allow_value('feature', 'bug').for(:story_type) }
    it { should_not allow_value('None', 'blah').for(:story_type) }

    # RN[2016/12/26]: 'should not allow due date in past' validation is removed to support updating old stories and importing stories from third party
    it { should allow_value(Date.yesterday, Date.tomorrow).for(:due_at) }
  end

  context 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:requester).class_name('User').with_foreign_key('requester_id') }
    it { should have_many(:comments) }
    it { should have_many(:attachments) }

    it { is_expected.to have_many :notifications }
  end


  context 'default values' do
    expected_values = {state: 'unstarted', story_type: 'feature'}

    expected_values.each do |key, val|
      it { is_expected.to have_value(key, val) }
    end
  end

  context 'callbacks' do
    let!(:story) { create(:story, title: 'story one', requester: user, project: project) }

    describe 'set_position' do
      it 'assigns first position' do
        expect(story.position).to eq 1
      end

      it 'assigns second position' do
        story = create(:story, title: 'story two', requester: user, project: project)
        expect(story.position).to eq 2
      end

      it 'assigns first position for first story of an other project' do
        another_project = create(:project, owner: user)
        story = create(:story, title: 'story three', requester: user, project: another_project)
        expect(story.position).to eq 1
      end
    end

    describe 'current_ticket_id' do
      it 'assigns correct ticket_id to story' do
        expect(story.ticket_id).to eq 'test-1'
      end

      it 'increases current_ticket_id' do
        expect { create(:story, project: project, requester: user) }.to change { project.current_ticket_id }.by(1)
      end
    end
  end

  describe '#copy_to' do
    let(:owner_of_projects) { create(:user) }
    let(:base_project) { create(:project, title: 'Original story wala project', owner: owner_of_projects) }
    let(:target_project) { create(:project, title: 'Nawa project', owner: owner_of_projects) }

    context 'for simple story' do
      let(:simple_story_to_copy) { create(:story, title: 'sadi kapi wala story', priority: 'Medium', owner: owner_of_projects, requester: user, project: base_project) }
      let(:story_copy) { simple_story_to_copy.copy_to(target_project, owner_of_projects) }

      it 'should increment story count of target project' do
        expect { simple_story_to_copy.copy_to(target_project, owner_of_projects) }.to change { target_project.stories.count }.by(1)
      end

      it 'should return clone of simple story in target project' do
        expect(story_copy).to be_an_instance_of(Story)
        expect(story_copy).to be_persisted
        expect(story_copy).not_to eq simple_story_to_copy
        expect(target_project.stories).not_to include(simple_story_to_copy)
        expect(target_project.stories).to include(story_copy)
        expect(story_copy.project).to eq target_project
        expect(story_copy.owner).to eq owner_of_projects
        expect(story_copy.requester).to eq owner_of_projects
        expect(story_copy.priority).to eq 'Medium'
        expect(story_copy.title).to eq 'sadi kapi wala story'
      end

      it 'should not remove original story from source project' do
        story_copy
        expect { simple_story_to_copy.copy_to(target_project, owner_of_projects) }.not_to change { base_project.stories.count }
        expect(base_project.stories).to include(simple_story_to_copy)
      end

      context 'requester of story is not in the target project' do
        let(:other_user) { create(:user) }
        let(:requester) { create(:story, title: 'naye requester wala story', requester: other_user, project: base_project) }
        let(:story_copy) { requester.copy_to(target_project, owner_of_projects) }

        it 'should set the requester to story mover' do
          expect(story_copy.requester).to eq owner_of_projects
        end
      end

      context 'requester of story is also present in the target project' do
        let(:other_user) { create(:user) }
        let(:requester) { create(:story, title: 'naye requester wala story', requester: other_user, project: base_project) }
        let(:story_copy) { requester.copy_to(target_project, owner_of_projects) }

        before { target_project.contributions.create(user_id: other_user.id, role: 'Member') }

        it 'should set the requester to requester of original story' do
          expect(story_copy.requester).to eq other_user
        end
      end
    end

    context 'for story with comments' do
      it 'should copy story and not comments when with_comments is false' do
        expect do
          story_with_comments = create(:story, :with_comments, comments_count: 3, requester: owner_of_projects, project: base_project)
          story_with_comments.copy_to(target_project, owner_of_projects, with_comments: false)
        end.not_to change { Comment.where(commentable: target_project.stories).count }
      end

      it 'should copy story and comments when with_comments is true' do
        expect do
          story_with_comments = create(:story, :with_comments, comments_count: 4, requester: owner_of_projects, project: base_project)
          story_with_comments.copy_to(target_project, owner_of_projects, with_comments: true)
        end.to change { Comment.where(commentable: target_project.stories).count }.by(4)
      end

      context 'when with_comments is set to true' do
        let(:story_commenter) { create(:user) }
        let(:story_from_commenter) { create(:story, :with_comments, comments_count: 3, commenter: story_commenter, project: base_project) }
        let(:story_copy) { story_from_commenter.copy_to(target_project, owner_of_projects, with_comments: true) }

        context 'commenter of story is not present in the target project' do
          it 'should set the commenter to mover of the story' do
            expect(story_copy.comments.map(&:user).uniq).to eq [owner_of_projects]
          end
        end

        context 'commenter of story is also present in the target project' do
          before { target_project.contributions.create(user_id: story_commenter.id, role: 'Member') }

          it 'should set the commenter to commenter of original story' do
            expect(story_copy.comments.map(&:user).uniq).to eq [story_commenter]
          end
        end
      end
    end

    context 'for story with attachments' do
      it 'should copy story and not attachments when with_attachments is false' do
        expect do
          story_with_attachments = create(:story, :with_attachments, attachments_count: 2, requester: owner_of_projects, project: base_project)
          story_with_attachments.copy_to(target_project, owner_of_projects, with_attachments: false)
        end.not_to change { Attachment.where(attachable: target_project.stories).count }
      end

      it 'should copy story and attachments when with_attachments is true' do
        expect do
          story_with_attachments = create(:story, :with_attachments, attachments_count: 3, real_attachments: true, requester: owner_of_projects, project: base_project)
          story_with_attachments.copy_to(target_project, owner_of_projects, with_attachments: true)
        end.to change { Attachment.where(attachable: target_project.stories).count }.by(3)

        expect(File).to exist(target_project.stories.last.attachments.last.document.path)
      end
    end
  end

  # UA[2017/01/08] - REVIEW TAG SPECS, TAGGED_WITH, TAG_LIST="a b, c99, #d"
  context 'stories with tags' do
    let(:admin_user) { create(:user, name: 'Admin User') }
    let(:network_project) { create(:project, title: 'Network App', owner: admin_user) }
    let(:base_tagged_story) { create(:story, title: 'base tag story', tag_list: 'uk base, us base', requester: admin_user, project: network_project) }

    it 'creating story with correct tags' do
      expect do
        base_tagged_story
      end.to change { network_project.stories.count }.by(1)

      # https://github.com/mbleigh/acts-as-taggable-on#relationships
      # Objects will be returned in descending order based on the total number of matched tags.
      expect(network_project.stories.last.tags.map(&:to_s)).to eq(['us base', 'uk base'])
      expect(network_project.stories.last).to have_attributes(:tag_list => ['us base', 'uk base'])
      expect(network_project.stories.tagged_with(['us base', 'uk base']).count).to eq 1
      expect(network_project.stories.last.tag_list.count).to eq 2

      story = network_project.stories.last
      story.tag_list.add('awesome', 'slick')
      story.save
      story.reload

      expect(network_project.stories.last.tag_list.count).to eq 4

      story.tag_list.remove('awesome')
      story.save
      story.reload

      expect(network_project.stories.last.tag_list.count).to eq 3

    end

    it 'creating story with wrong tags' do
      story = build(:story, title: 'hit tag story', tag_list: '#white base, @black base', requester: admin_user, project: network_project)
      story.save

      expect(story.errors[:tag_list]).to_not be nil
      expect(build(:story, title: 'hit tag story', tag_list: '<white base, black base', requester: admin_user, project: network_project)).to_not be_valid
      expect { should_not create(:story, title: 'hit tag story', tag_list: '#white base, @black base', requester: admin_user, project: network_project) }
    end
  end

  context 'class level methods' do
    # This is sample data used for testing Search and CSV exports
    # Changing this data may break these specs. So dont change or Add/Remove this data.
    let!(:story) { create(:story, title: 'story one', description: 'story 1 create ERD', state: 'started', requester: user, project: project) }
    let!(:completed_story) { create(:story, title: 'story two', description: 'story 2 create DB', state: 'finished', requester: user, project: project) }
    let!(:another_story) { create(:story, title: 'another ', description: 'another description', state: 'accepted', requester: user, project: project) }

    describe '#filter_stories', pending: 'feature has been redesigned or removed' do
      it 'returns non-completed stories meeting the search criteria' do
        stories = Story.filter_stories(search_text: 'story')

        expect(stories.count).to eq 1
        expect(stories.first.title).to eq 'story one'
      end

      it 'returns all non-completed stories when no search text is given' do
        stories = Story.filter_stories(search_text: nil)
        expect(stories.count).to eq 1
      end

      it 'returns ALL stories (completed + non-completed)' do
        stories = Story.filter_stories(include_completed: true)
        expect(stories.count).to eq 3
      end

      it 'includes completed stories meeting search criteria' do
        stories = Story.filter_stories(search_text: 'story', include_completed: true)
        expect(stories.count).to eq 2
      end
    end

    describe '#search' do
      it 'searches by single word in description' do
        expect(Story.search('create').count).to eq 2
      end

      it 'searches by multiple words in description' do
        expect(Story.search('create create DB').count).to eq 1
      end

      it 'proves case-insensitive search' do
        expect(Story.search('CreaTE Erd').count).to eq 1
      end

      it 'returns unique records' do
        expect(Story.search('story').count).to eq 2
      end
    end

    describe 'CSV import/export' do
      let!(:story1) { create(:story, title: 'create psd', description: 'story one in group',
                            state: 'started', requester: user, project: project) }

      let!(:story2) { create(:story, title: 'create html templates', description: 'story two in group',
                            state: 'rejected', priority: 'Medium', requester: user, project: project) }


      describe '#to_csv (export to CSV file)' do
        let!(:exported_string) { Story.all.to_csv }
        let!(:exported_array) { CSV.parse(exported_string, headers: true) }
        let!(:exported_data) { exported_array.map { |row| row.to_hash } }


        it 'exports correct number of rows' do
          expect(exported_array.length).to eq 5
        end

        describe 'Exported Values' do
          subject! { exported_data.find { |d| d['title'] == 'create html templates' } }

          expected_values = {
              title: 'create html templates', description: 'story two in group',
              state: 'rejected', priority: 'Medium'
          }

          expected_values.each do |k, v|
            it { is_expected.to have_value k, v }
          end
        end
      end

      describe '#import (from CSV)' do
        let(:csv_file) { File.open Rails.root.join('spec', 'files', 'stories.csv') }

        before { Story.import csv_file, project, user }

        it 'imports all records' do
          expect(Story.count).to eq 8 # 5 existing and 3 newly created from CSV
        end

        describe 'imported story' do
          subject { Story.last }

          expected_values = {
              title: 'add authentication', description: 'use devise',
              state: 'started'
          }

          expected_values.each do |k, v|
            it { is_expected.to have_value k, v }
          end
        end
      end
    end
  end

  describe '#destroy' do
    let(:camp_project_owner) { create(:user) }
    let(:camp_project) { create(:project, title: 'US project', owner: camp_project_owner) }
    let(:story_with_comments) { create(:story, :with_comments, comments_count: 3, requester: camp_project_owner, project: camp_project) }
    let(:story_with_attachments) { create(:story, :with_attachments, attachments_count: 4, requester: camp_project_owner, project: camp_project) }
    let(:story_with_real_attachments) { create(:story, :with_attachments, attachments_count: 1, real_attachments: true, requester: camp_project_owner, project: camp_project) }
    let(:comment_with_real_attachments) { create(:comment, :with_attachments, attachments_count: 2, real_attachments: true, user: camp_project_owner, commentable: story_with_comments) }

    it 'deletes story with comments' do
      expect do
        story_with_comments
      end.to change { camp_project.stories.count }.by(1)
                 .and change { Comment.where(commentable: camp_project.stories).count }.by(3)

      expect do
        story_with_comments.destroy
      end.to change { camp_project.stories.count }.by(-1)
                 .and change { Comment.where(commentable: camp_project.stories).count }.by(-3)
    end

    it 'deletes story with attachments' do
      expect do
        story_with_attachments
      end.to change { camp_project.stories.count }.by(1)
                 .and change { Attachment.where(attachable: camp_project.stories).count }.by(4)

      expect do
        story_with_attachments.destroy
      end.to change { camp_project.stories.count }.by(-1)
                 .and change { Attachment.where(attachable: camp_project.stories).count }.by(-4)
    end

    it 'deletes story with real attachments' do
      story_with_real_attachments
      path = story_with_real_attachments.attachments.first.document.path
      expect(File).to exist(path)

      story_with_real_attachments.destroy
      expect(File).not_to exist(path)
    end

    it 'deletes story having comments with attachments' do
      expect do
        comment_with_real_attachments
      end.to change { Attachment.where(attachable: story_with_comments.comments).count }.by(2)

      path = story_with_comments.comments.last.attachments.first.document.path
      expect(File).to exist(path)

      story_with_comments.destroy
      expect(File).not_to exist(path)
    end
  end

  # UA[2016/11/29] - METHOD_REMOVED '#assigned_to_me' # REFACTOR SPECS TO TEST NEW SCENARIOS
  # describe '#assigned_to_me' do
  #   let(:another_user) { create(:user) }
  #
  #   context 'assigned to nobody' do
  #     let!(:story) { create(:story, state: 'unstarted', project: project, requester: user) }
  #
  #     before { story.assigned_to_me(another_user) }
  #     it 'assigns story to a user' do
  #       expect(story.assigned_to).to eq another_user.id
  #     end
  #   end
  #
  #   context 'already assigned' do
  #     let!(:story) { create(:story, project: project, requester: user, assigned_to: user.id) }
  #
  #     before { story.assigned_to_me(another_user) }
  #     it 'will not assign story' do
  #       expect(story.assigned_to).to eq user.id
  #     end
  #   end
  #
  #   context 'already in state' do
  #     let!(:story) { create(:story, project: project, requester: user, assigned_to: user.id, state: 'started') }
  #
  #     before { story.assigned_to_me(another_user) }
  #     it 'will not assign story' do
  #       expect(story.assigned_to).to eq user.id
  #     end
  #   end
  # end
  # UA[2016/11/29] - METHOD REMOVED '#set_state' # REFACTOR SPECS TO TEST NEW SCENARIOS
  # describe '#set_state' do
  #   before { story.set_state(user, 'started') }
  #
  #   context 'Story is assigned to that user' do
  #     let!(:story) { create(:story, project: project, requester: user, assigned_to: user.id) }
  #
  #     it 'will change state' do
  #       expect(story.state).to eq 'started'
  #     end
  #   end
  #
  #   context 'Story is NOT assigned to that user' do
  #     let(:another_user) { create(:user) }
  #     let!(:story) { create(:story, project: project, requester: user, assigned_to: another_user.id) }
  #
  #     it 'would NOT changes state' do
  #       expect(story.state).to eq 'unstarted' # Default value
  #     end
  #   end
  # end

  describe 'notifications' do
    let(:owner) { create(:user, name: 'Owner name') }
    let(:other_user) { create(:user) }

    # Also creating one member user. Notification should be created for all members except performer.
    let(:project) { create(:project, owner: owner, title: 'T E S Ting', member_users: [other_user]) }

    it { is_expected.to be_a Notifiable }
    it { is_expected.to respond_to :create_user_notifications }
    # it { is_expected.to callback(:create_user_notifications).after(:commit) }

    it 'implements act_as_notifiable' do
      expect(Story).to respond_to(:act_as_notifiable).with(1).argument
      # expect(Story).to receive(:act_as_notifiable).with(hash_including(performer: anything, receivers: :notification_receivers, content_method: :title))
    end


    describe '#notification_receivers' do
      let(:story) { build(:story, owner: owner, project: project) }

      context 'when owner is performer' do
        before do
          story.performer = owner
        end

        it 'notifies other user' do
          expect(story.send(:notification_receivers).count).to eq(1)
          expect(story.send(:notification_receivers)).to include(other_user)
        end
      end

      context 'when other user is performer' do
        before do
          story.performer = other_user
        end
        it 'notifies owner' do
          expect(story.send(:notification_receivers).count).to eq(1)
          expect(story.send(:notification_receivers)).to include(owner)
        end
      end

      context 'when project has no contributions and owner is performer' do
        let(:project) { create(:project, owner: owner) }

        before do
          story.performer = owner
        end

        it 'does not generate any notification' do
          expect(story.send(:notification_receivers).count).to eq(0)
        end
      end
    end

    describe 'notifiable configurations' do
      let(:config) { Story.notifiable_config }

      it 'assigns correct values' do
        expect(config[:notifiable_attributes]).to eq ['title', 'description', 'priority', 'state', 'owner_id']
        expect(config[:performer]).to eq :performer
        expect(config[:receivers]).to eq :notification_receivers
        expect(config[:content_method]).to eq :title
      end

      describe 'Non notifiable attributes' do
        let!(:story) { create(:story, project: project, title: 'Story for testing notifications', id: 1001, performer: owner) }

        it 'does not create notifications if position is changed' do
          expect { story.update_attributes(position: 2) }.to change(Notification, :count).by(0)
        end
      end
    end

    context 'on create' do
      let(:story) { build(:story, project: project, title: 'Story for testing notifications', id: 1001, performer: owner) }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { story.save }.to change(Notification, :count).by(1)

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq story

        expect(notification.text).to eq 'Story for testing notifications'
      end
    end

    context 'on create' do
      let(:story) { build(:story, project: project, title: 'Story for testing notifications', id: 1001, performer: owner) }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { story.save }.to change(Notification, :count).by(1)

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq story

        expect(notification.text).to eq 'Story for testing notifications'
        expect(notification.action).to eq 'Created'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Story'
        expect(notification.resource_fid).to eq 'test-1'
        expect(notification.resource_link).to eq '/projects/test/stories/test-1'
        expect(notification.project_fid).to eq 'test'
      end
    end


    context 'on update' do
      let!(:story) { create(:story, project: project, performer: owner, title: 'Story for testing notifications') }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { story.update_attributes(title: 'My updated story') }.to change(Notification, :count).by(1)

        expect(notification.action).to eq 'Updated'
        expect(notification.text).to eq 'My updated story'
      end
    end

    context 'on destroy' do
      let!(:story) { create(:story, project: project, performer: owner, title: 'Story for testing notifications') }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { story.destroy }.to change(Notification, :count).by(1)
        expect(notification.notifiable).to eq nil # as notifiable is deleted
        expect(notification.action).to eq 'Deleted'
        expect(notification.text).to eq 'Story for testing notifications'
      end
    end

  end

end
