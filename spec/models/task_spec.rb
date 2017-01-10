# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  title       :string
#  description :text
#  project_id  :integer
#  priority    :string           default("None")
#  due_at      :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  state       :string           default("unscheduled")
#  owner_id    :integer
#  reporter_id :integer
#  position    :integer
#  ticket_id   :string
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


RSpec.describe Task, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user, title: 'T E S Ting') }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:project) }

    it { should allow_value('unscheduled', 'unstarted', 'started', 'paused', 'finished', 'delivered', 'rejected',
                            'accepted').for(:state) }
    it { should_not allow_value('blah').for(:state) }

    it { should allow_value('None', 'Low', 'Medium', 'High').for(:priority) }
    it { should_not allow_value('blah').for(:priority) }
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:reporter).class_name('User').with_foreign_key('reporter_id') }
    it { should have_many(:comments) }
    it { should have_many(:attachments) }

    it { is_expected.to have_many :notifications }
  end


  describe 'default values' do
    expected_values = {state: 'unstarted', priority: 'None'}

    expected_values.each do |key, val|
      it { is_expected.to have_value(key, val) }
    end
  end

  describe 'callbacks' do
    let!(:task) { create(:task, title: 'task one', reporter: user, project: project) }

    describe 'set_position' do
      it 'assigns first position' do
        expect(task.position).to eq 1
      end

      it 'assigns second position' do
        task = create(:task, title: 'task two', reporter: user, project: project)
        expect(task.position).to eq 2
      end

      it 'assigns first position for first task of an other project' do
        another_project = create(:project, owner: user)
        task = create(:task, title: 'task three', reporter: user, project: another_project)
        expect(task.position).to eq 1
      end
    end

    describe 'current_ticket_id' do
      it 'assigns correct ticket_id to task' do
        expect(task.ticket_id).to eq 'test-1'
      end

      it 'increases current_ticket_id' do
        expect { create(:task, project: project, reporter: user) }.to change { project.current_ticket_id }.by(1)
      end
    end
  end

  describe '#copy_to' do
    let(:owner_of_projects) { create(:user) }
    let(:base_project) { create(:project, title: 'Original task wala project', owner: owner_of_projects) }
    let(:target_project) { create(:project, title: 'Nawa project', owner: owner_of_projects) }

    context 'for simple task' do
      let(:simple_task_to_copy) { create(:task, title: 'sadi kapi wala task', priority: 'Medium', owner: owner_of_projects, reporter: user, project: base_project) }
      let(:task_copy) { simple_task_to_copy.copy_to(target_project, owner_of_projects) }

      it 'should increment task count of target project' do
        expect { simple_task_to_copy.copy_to(target_project, owner_of_projects) }.to change { target_project.tasks.count }.by(1)
      end

      it 'should return clone of simple task in target project' do
        expect(task_copy).to be_an_instance_of(Task)
        expect(task_copy).to be_persisted
        expect(task_copy).not_to eq simple_task_to_copy
        expect(target_project.tasks).not_to include(simple_task_to_copy)
        expect(target_project.tasks).to include(task_copy)
        expect(task_copy.project).to eq target_project
        expect(task_copy.owner).to eq owner_of_projects
        expect(task_copy.reporter).to eq owner_of_projects
        expect(task_copy.priority).to eq 'Medium'
        expect(task_copy.title).to eq 'sadi kapi wala task'
      end

      it 'should not remove original task from source project' do
        task_copy
        expect { simple_task_to_copy.copy_to(target_project, owner_of_projects) }.not_to change { base_project.tasks.count }
        expect(base_project.tasks).to include(simple_task_to_copy)
      end

      context 'reporter of task is not in the target project' do
        let(:other_user) { create(:user) }
        let(:task_with_other_reporter) { create(:task, title: 'naye reporter wala task', reporter: other_user, project: base_project) }
        let(:task_copy) { task_with_other_reporter.copy_to(target_project, owner_of_projects) }

        it 'should set the reporter to task mover' do
          expect(task_copy.reporter).to eq owner_of_projects
        end
      end

      context 'reporter of task is also present in the target project' do
        let(:other_user) { create(:user) }
        let(:task_with_other_reporter) { create(:task, title: 'naye reporter wala task', reporter: other_user, project: base_project) }
        let(:task_copy) { task_with_other_reporter.copy_to(target_project, owner_of_projects) }

        before { target_project.contributions.create(user_id: other_user.id, role: 'Member') }

        it 'should set the reporter to reporter of original task' do
          expect(task_copy.reporter).to eq other_user
        end
      end
    end

    context 'for task with comments' do
      it 'should copy task and not comments when with_comments is false' do
        expect do
          task_with_comments = create(:task, :with_comments, comments_count: 3, reporter: owner_of_projects, project: base_project)
          task_with_comments.copy_to(target_project, owner_of_projects, with_comments: false)
        end.not_to change { Comment.where(commentable: target_project.tasks).count }
      end

      it 'should copy task and comments when with_comments is true' do
        expect do
          task_with_comments = create(:task, :with_comments, comments_count: 4, reporter: owner_of_projects, project: base_project)
          task_with_comments.copy_to(target_project, owner_of_projects, with_comments: true)
        end.to change { Comment.where(commentable: target_project.tasks).count }.by(4)
      end

      context 'when with_comments is set to true' do
        let(:task_commenter) { create(:user) }
        let(:task_from_commenter) { create(:task, :with_comments, comments_count: 3, commenter: task_commenter, project: base_project) }
        let(:task_copy) { task_from_commenter.copy_to(target_project, owner_of_projects, with_comments: true) }

        context 'commenter of task is not present in the target project' do
          it 'should set the commenter to mover of the task' do
            expect(task_copy.comments.map(&:user).uniq).to eq [owner_of_projects]
          end
        end

        context 'commenter of task is also present in the target project' do
          before { target_project.contributions.create(user_id: task_commenter.id, role: 'Member') }

          it 'should set the commenter to commenter of original task' do
            expect(task_copy.comments.map(&:user).uniq).to eq [task_commenter]
          end
        end
      end
    end

    context 'for task with attachments' do
      it 'should copy task and not attachments when with_attachments is false' do
        expect do
          task_with_attachments = create(:task, :with_attachments, attachments_count: 2, reporter: owner_of_projects, project: base_project)
          task_with_attachments.copy_to(target_project, owner_of_projects, with_attachments: false)
        end.not_to change { Attachment.where(attachable: target_project.tasks).count }
      end

      it 'should copy task and attachments when with_attachments is true' do
        expect do
          task_with_attachments = create(:task, :with_attachments, attachments_count: 3, real_attachments: true, reporter: owner_of_projects, project: base_project)
          task_with_attachments.copy_to(target_project, owner_of_projects, with_attachments: true)
        end.to change { Attachment.where(attachable: target_project.tasks).count }.by(3)

        expect(File).to exist(target_project.tasks.last.attachments.last.document.path)
      end
    end
  end

  # UA[2017/01/08] - REVIEW TAG SPECS, TAGGED_WITH, TAG_LIST="a b, c99, #d"
  context 'tasks with tags' do
    let(:admin_user) { create(:user, name: 'Admin User') }
    let(:network_project) { create(:project, title: 'Network App', owner: admin_user) }
    let(:base_tagged_task) { create(:task, title: 'base tag task', tag_list: 'uk base, us base', reporter: admin_user, project: network_project) }

    it 'creating task with correct tags' do
      expect do
        base_tagged_task
      end.to change { network_project.tasks.count }.by(1)

      # https://github.com/mbleigh/acts-as-taggable-on#relationships
      # Objects will be returned in descending order based on the total number of matched tags.
      expect(network_project.tasks.last.tags.map(&:to_s)).to eq(['us base', 'uk base'])
      expect(network_project.tasks.last).to have_attributes(:tag_list => ['us base', 'uk base'])
      expect(network_project.tasks.tagged_with(['us base', 'uk base']).count).to eq 1
      expect(network_project.tasks.last.tag_list.count).to eq 2

      task = network_project.tasks.last
      task.tag_list.add('awesome', 'slick')
      task.save
      task.reload

      expect(network_project.tasks.last.tag_list.count).to eq 4

      task.tag_list.remove('awesome')
      task.save
      task.reload

      expect(network_project.tasks.last.tag_list.count).to eq 3

    end

    it 'creating task with wrong tags' do
      task = build(:task, title: 'hit tag task', tag_list: '#white base, @black base', reporter: admin_user, project: network_project)
      task.save

      expect(task.errors[:tag_list]).to_not be nil
      expect(build(:task, title: 'hit tag task', tag_list: '<white base, black base', reporter: admin_user, project: network_project)).to_not be_valid
      expect { should_not create(:task, title: 'hit tag task', tag_list: '#white base, @black base', reporter: admin_user, project: network_project) }
    end
  end

  describe 'class level methods' do
    # This is sample data used for testing Search and CSV exports
    # Changing this data may break these specs. So dont change or Add/Remove this data.
    let!(:task) { create(:task, title: 'task one', description: 'task 1 create ERD', state: 'started', reporter: user, project: project) }
    let!(:completed_task) { create(:task, title: 'task two', description: 'task 2 create DB', state: 'finished', reporter: user, project: project) }
    let!(:another_task) { create(:task, title: 'another ', description: 'another description', state: 'accepted', reporter: user, project: project) }

    describe '#filter_tasks', pending: 'feature has been redesigned or removed' do
      it 'returns non-completed tasks meeting the search criteria' do
        tasks = Task.filter_tasks(search_text: 'task')

        expect(tasks.count).to eq 1
        expect(tasks.first.title).to eq 'task one'
      end

      it 'returns all non-completed tasks when no search text is given' do
        tasks = Task.filter_tasks(search_text: nil)
        expect(tasks.count).to eq 1
      end

      it 'returns ALL tasks (completed + non-completed)' do
        tasks = Task.filter_tasks(include_completed: true)
        expect(tasks.count).to eq 3
      end

      it 'includes completed tasks meeting search criteria' do
        tasks = Task.filter_tasks(search_text: 'task', include_completed: true)
        expect(tasks.count).to eq 2
      end
    end

    describe '#search' do
      it 'searches by single word in description' do
        expect(Task.search('create').count).to eq 2
      end

      it 'searches by multiple words in description' do
        expect(Task.search('create create DB').count).to eq 1
      end

      it 'proves case-insensitive search' do
        expect(Task.search('CreaTE Erd').count).to eq 1
      end

      it 'returns unique records' do
        expect(Task.search('task').count).to eq 2
      end
    end

    describe 'CSV import/export' do
      let!(:task1) { create(:task, title: 'create psd', description: 'task one in group',
                            state: 'started', reporter: user, project: project) }

      let!(:task2) { create(:task, title: 'create html templates', description: 'task two in group',
                            state: 'rejected', priority: 'Medium', reporter: user, project: project) }


      describe '#to_csv (export to CSV file)' do
        let!(:exported_string) { Task.all.to_csv }
        let!(:exported_array) { CSV.parse(exported_string, headers: true) }
        let!(:exported_data) { exported_array.map { |row| row.to_hash } }


        it 'exports correct number of rows' do
          expect(exported_array.length).to eq 5
        end

        describe 'Exported Values' do
          subject! { exported_data.find { |d| d['title'] == 'create html templates' } }

          expected_values = {
              title: 'create html templates', description: 'task two in group',
              state: 'rejected', priority: 'Medium'
          }

          expected_values.each do |k, v|
            it { is_expected.to have_value k, v }
          end
        end
      end

      describe '#import (from CSV)' do
        let(:csv_file) { File.open Rails.root.join('spec', 'files', 'tasks.csv') }

        before { Task.import csv_file, project, user }

        it 'imports all records' do
          expect(Task.count).to eq 8 # 5 existing and 3 newly created from CSV
        end

        describe 'imported task' do
          subject { Task.last }

          expected_values = {
              title: 'add authentication', description: 'use devise',
              state: 'started', priority: 'None'
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
    let(:task_with_comments) { create(:task, :with_comments, comments_count: 3, reporter: camp_project_owner, project: camp_project) }
    let(:task_with_attachments) { create(:task, :with_attachments, attachments_count: 4, reporter: camp_project_owner, project: camp_project) }
    let(:task_with_real_attachments) { create(:task, :with_attachments, attachments_count: 1, real_attachments: true, reporter: camp_project_owner, project: camp_project) }
    let(:comment_with_real_attachments) { create(:comment, :with_attachments, attachments_count: 2, real_attachments: true, user: camp_project_owner, commentable: task_with_comments) }

    it 'deletes task with comments' do
      expect do
        task_with_comments
      end.to change { camp_project.tasks.count }.by(1)
                 .and change { Comment.where(commentable: camp_project.tasks).count }.by(3)

      expect do
        task_with_comments.destroy
      end.to change { camp_project.tasks.count }.by(-1)
                 .and change { Comment.where(commentable: camp_project.tasks).count }.by(-3)
    end

    it 'deletes task with attachments' do
      expect do
        task_with_attachments
      end.to change { camp_project.tasks.count }.by(1)
                 .and change { Attachment.where(attachable: camp_project.tasks).count }.by(4)

      expect do
        task_with_attachments.destroy
      end.to change { camp_project.tasks.count }.by(-1)
                 .and change { Attachment.where(attachable: camp_project.tasks).count }.by(-4)
    end

    it 'deletes task with real attachments' do
      task_with_real_attachments
      path = task_with_real_attachments.attachments.first.document.path
      expect(File).to exist(path)

      task_with_real_attachments.destroy
      expect(File).not_to exist(path)
    end

    it 'deletes task having comments with attachments' do
      expect do
        comment_with_real_attachments
      end.to change { Attachment.where(attachable: task_with_comments.comments).count }.by(2)

      path = task_with_comments.comments.last.attachments.first.document.path
      expect(File).to exist(path)

      task_with_comments.destroy
      expect(File).not_to exist(path)
    end
  end

  # UA[2016/11/29] - METHOD_REMOVED '#assigned_to_me' # REFACTOR SPECS TO TEST NEW SCENARIOS
  # describe '#assigned_to_me' do
  #   let(:another_user) { create(:user) }
  #
  #   context 'assigned to nobody' do
  #     let!(:task) { create(:task, state: 'unstarted', project: project, reporter: user) }
  #
  #     before { task.assigned_to_me(another_user) }
  #     it 'assigns task to a user' do
  #       expect(task.assigned_to).to eq another_user.id
  #     end
  #   end
  #
  #   context 'already assigned' do
  #     let!(:task) { create(:task, project: project, reporter: user, assigned_to: user.id) }
  #
  #     before { task.assigned_to_me(another_user) }
  #     it 'will not assign task' do
  #       expect(task.assigned_to).to eq user.id
  #     end
  #   end
  #
  #   context 'already in state' do
  #     let!(:task) { create(:task, project: project, reporter: user, assigned_to: user.id, state: 'started') }
  #
  #     before { task.assigned_to_me(another_user) }
  #     it 'will not assign task' do
  #       expect(task.assigned_to).to eq user.id
  #     end
  #   end
  # end
  # UA[2016/11/29] - METHOD REMOVED '#set_state' # REFACTOR SPECS TO TEST NEW SCENARIOS
  # describe '#set_state' do
  #   before { task.set_state(user, 'started') }
  #
  #   context 'Task is assigned to that user' do
  #     let!(:task) { create(:task, project: project, reporter: user, assigned_to: user.id) }
  #
  #     it 'will change state' do
  #       expect(task.state).to eq 'started'
  #     end
  #   end
  #
  #   context 'Task is NOT assigned to that user' do
  #     let(:another_user) { create(:user) }
  #     let!(:task) { create(:task, project: project, reporter: user, assigned_to: another_user.id) }
  #
  #     it 'would NOT changes state' do
  #       expect(task.state).to eq 'unstarted' # Default value
  #     end
  #   end
  # end

  it 'should have title' do
    expect(build(:task, project: project, title: nil)).to_not be_valid
  end

  # TODO: This validation is rejected in module due to it will cause issue while updating old task and importing tasks from third party
  # RN[2016/12/26]
  # it 'should not allow due date in past', pending: 'Add validation in model if required.' do
  #   expect(build(:task, priority: 'Medium', project: project, due_at: (Date.today - 1))).to_not be_valid
  # end

  it 'should allow nil due date' do
    expect(build(:task, project: project, due_at: nil)).to be_valid
  end

  it 'should allow us to create' do
    expect(create(:task, priority: 'Low', project: project, reporter: project.owner).priority).to eq('Low')
    expect(create(:task, priority: 'Low', project: project, state: 'finished', reporter: project.owner).state).to eq('finished')
    expect(create(:task, priority: 'Medium', project: project, reporter: project.owner).priority).to eq('Medium')
    expect(create(:task, priority: 'High', project: project, state: 'unstarted', reporter: project.owner).priority).to eq('High')
  end

  describe 'notifications' do
    let(:owner) { create(:user, name: 'Owner name') }
    let(:other_user) { create(:user) }

    # Also creating one member user. Notification should be created for all members except performer.
    let(:project) { create(:project, owner: owner, title: 'T E S Ting', member_users: [other_user]) }

    it { is_expected.to be_a Notifiable }
    it { is_expected.to respond_to :create_user_notifications }
    # it { is_expected.to callback(:create_user_notifications).after(:commit) }

    it 'implements act_as_notifiable' do
      expect(Task).to respond_to(:act_as_notifiable).with(1).argument
      # expect(Task).to receive(:act_as_notifiable).with(hash_including(performer: anything, receivers: :notification_receivers, content_method: :title))
    end


    describe '#notification_receivers' do
      let(:task) { build(:task, owner: owner, project: project) }

      context 'when owner is performer' do
        before do
          task.performer = owner
        end

        it 'notifies other user' do
          expect(task.send(:notification_receivers).count).to eq(1)
          expect(task.send(:notification_receivers)).to include(other_user)
        end
      end

      context 'when other user is performer' do
        before do
          task.performer = other_user
        end
        it 'notifies owner' do
          expect(task.send(:notification_receivers).count).to eq(1)
          expect(task.send(:notification_receivers)).to include(owner)
        end
      end

      context 'when project has no contributions and owner is performer' do
        let(:project) { create(:project, owner: owner) }

        before do
          task.performer = owner
        end

        it 'does not generate any notification' do
          expect(task.send(:notification_receivers).count).to eq(0)
        end
      end
    end

    context 'test' do
      before do
        # we can stub performer
        # allow(task).to receive(:performer).and_return(owner)
        # allow_any_instance_of(Task).to receive(:performer).and_return(owner)
        task.performer = owner
      end
    end

    context 'on create' do
      let(:task) { build(:task, project: project, title: 'Task for testing notifications', id: 1001, performer: owner) }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { task.save }.to change(Notification, :count).by(1)

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq task

        expect(notification.text).to eq 'Task for testing notifications'
      end
    end

    context 'on create' do
      let(:task) { build(:task, project: project, title: 'Task for testing notifications', id: 1001, performer: owner) }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { task.save }.to change(Notification, :count).by(1)

        expect(notification.receiver).to eq other_user
        expect(notification.performer_name).to eq 'Owner name'
        expect(notification.notifiable).to eq task

        expect(notification.text).to eq 'Task for testing notifications'
        expect(notification.action).to eq 'Created'
        expect(notification.resource_id).to eq 1001
        expect(notification.resource_type).to eq 'Task'
        expect(notification.resource_fid).to eq 'test-1'
        expect(notification.resource_link).to eq '/projects/test/tasks/test-1'
        expect(notification.project_fid).to eq 'test'
      end
    end


    context 'on update' do
      let!(:task) { create(:task, project: project, performer: owner, title: 'Task for testing notifications') }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { task.update_attributes(title: 'My updated task') }.to change(Notification, :count).by(1)

        expect(notification.action).to eq 'Updated'
        expect(notification.text).to eq 'My updated task'
      end
    end

    context 'on destroy' do
      let!(:task) { create(:task, project: project, performer: owner, title: 'Task for testing notifications') }
      let(:notification) { other_user.notifications.last }

      it 'creates notifications' do
        expect { task.destroy }.to change(Notification, :count).by(1)
        expect(notification.notifiable).to eq nil # as notifiable is deleted
        expect(notification.action).to eq 'Deleted'
        expect(notification.text).to eq 'Task for testing notifications'
      end
    end

  end

end
