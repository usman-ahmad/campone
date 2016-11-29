require 'rails_helper'

describe 'attachments feature', type: :feature do
  let!(:owner) { create(:user) }
  let!(:project) { create(:project, owner: owner) }
  let!(:discussion) { create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner) }
  let!(:task) { create(:medium_priority_task, title: 'create erd diagram', project: project, commenter: owner, creator: owner) }
  let!(:project_attachment) { create(:attachment, attachment_file_name: 'test_attachment.jpg', attachment_content_type: 'image/jpeg', attachment_file_size: 559959, user_id: owner.id, attachable: project) }
  let!(:non_project_attachment) { create(:attachment, attachment_file_name: 'sample_attachment.jpg', attachment_content_type: 'image/png', attachment_file_size: 100392, user_id: owner.id, attachable: task) }

  before do
    login(owner.email, 'secretpassword')
  end

  context 'when there is an attachment' do

    before {
      visit project_attachments_path(project)
    }

    it 'uploads attachment', js: true, driver: :selenium do
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      expect(page).to have_content('test_attachment.jpg')
    end

    it 'downloads attachment', js: true, driver: :poltergeist do
      find('a', text: 'Download').click
      expect(response_headers['Content-Type']).to eq 'image/jpeg'
      expect(response_headers['Content-Disposition']).to eq 'attachment; filename="test_attachment.jpg"'
    end

    it 'enlists project attachment only' do
      expect(page).to have_content('test_attachment.jpg')
      expect(page).not_to have_content('sample_attachment.jpg')
    end
  end


  context 'when discussion' do
    before do
      project
      discussion
    end

    it 'should create discussion with attachment' do
      visit project_discussions_path(project)
      fill_in 'discussion_title', with: 'how to deliver'
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      page.find_all('img[title= "test_attachment.jpg"]')
    end

    it 'should attach file when update to discussion' do
      visit project_discussion_path(project, discussion)
      find('a', text: 'Edit').click
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      page.find_all('img[title= "test_attachment.jpg"]')
    end
  end

  context 'when tasks' do
    before do
      project
      task
    end
    it 'should create task with attachment' do
      visit project_tasks_path(project)
      fill_in 'task[title]', with: 'create erd diagram'
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click
      page.find_all('img[title= "test_attachment.jpg"]')
    end
    it 'should attach file when update to task' do
      visit project_task_path(project, task)
      find('a', text: 'Edit').click
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      sleep(2)
      find('input[name="commit"]').click
      page.find_all('img[title= "test_attachment.jpg"]')
    end
  end

end
