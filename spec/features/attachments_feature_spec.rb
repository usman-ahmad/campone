require 'rails_helper'

describe 'attachments feature', type: :feature, :js => true do
  let!(:owner) { create(:user) }
  let!(:project) { create(:project, owner: owner) }
  let!(:discussion_group) { create(:discussion_group, name: 'diagrams') }
  let!(:discussion) { create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner, discussion_group: discussion_group) }
  let!(:task_group) {create(:task_group, name: 'ruby')}
  let!(:task) {create(:medium_priority_task,title: 'create erd diagram',project: project , commenter: owner, creator: owner,task_group: task_group)}

  before do
    login(owner.email, 'secretpassword')
  end

  def test
    owner = FactoryGirl.create(:user)
    project = FactoryGirl.create(:project, owner: owner)
    discussion_group = FactoryGirl.create(:discussion_group, name: 'diagrams')
    discussion =FactoryGirl.create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner, discussion_group: discussion_group)
  end



  context 'when discussion' do
    before do
      project
      discussion
    end
    it 'should create discussion with attachment' do
      visit project_discussions_path(project)
      find('a', text: 'New Discussion').click
      page.find(:css, ".newgroup_icon").click
      fill_in 'discussion_discussion_group_attributes_name', with: 'notifications'
      fill_in 'discussion_title', with: 'how to deliver'
      fill_in 'discussion_content', with: 'there is a need of discussion about how to deliver notifications'
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      page.find('a', text: 'test_attachment.jpg').click
    end

    it 'should attach file when update to discussion' do
      visit project_discussion_path(project, discussion)
      find('a', text: 'Edit').click
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      page.find('a', text: 'test_attachment.jpg').click
    end
  end

  context 'when tasks' do
    before do
      project
      task
    end
    it 'should create task with attachment' do
      visit project_tasks_path(project)
      find('a', text: 'New Task').click
      page.find(:css, ".newgroup_icon").click
      fill_in 'task_task_group_attributes_name', with: 'ruby'
      fill_in 'task_title', with: 'create erd diagram'
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      page.find('a', text: 'test_attachment.jpg').click
    end
    it 'should attach file when update to task' do
      visit project_task_path(project, task)
      find('a', text: 'Edit').click
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      sleep(2)
      find('input[name="commit"]').click
      page.find('a', text: 'test_attachment.jpg').click
    end
  end

end
