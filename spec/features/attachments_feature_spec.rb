require 'rails_helper'

# UA[2016/12/01] - TODO - REFACTOR FEATURE SPECS - WHAT IS THE FEATURE HERE - WHAT ARE THE SCENARIOS
# https://www.relishapp.com/rspec/rspec-rails/docs/feature-specs/feature-spec
# https://github.com/eliotsykes/rspec-rails-examples

describe 'Attachments feature for Projects, Tasks and Discussions', type: :feature do
  let!(:owner) { create(:user, email: 'u@co.co', password: 'some_password', password_confirmation: 'some_password') }
  let!(:project) { create(:project, owner: owner) }

  before do
    login('u@co.co', 'some_password')
  end

  context 'when there is project with no attachments' do
    it 'uploads attachment' do
      visit project_attachments_path(project)

      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      find('input[name="commit"]').click

      expect(page).to have_content('test_attachment.jpg')
    end

    # UA[2016/12/01] - SHOULD THIS BE A JS SPEC?
    it 'downloads attachment', js: true do
      create(:attachment, attachment: File.new('spec/files/awesome_project_attachment.jpg'), user_id: owner.id, attachable: project)
      visit project_attachments_path(project)

      find('a', text: 'Download').click # UA[2016/12/01] - BRITTLE WAY TO ACCESS - REFACTOR IT

      expect(response_headers['Content-Type']).to eq 'image/jpeg'
      expect(response_headers['Content-Disposition']).to eq 'attachment; filename="awesome_project_attachment.jpg"'
    end
  end

  context 'when there is project with existing attachments, and we visit attachments page' do
    it 'enlists project attachment only' do
      # UA[2016/12/01] - TODO - CHECK IF STUBS COULD BE USED
      # UA[2016/12/01] - TODO - UPDATE FACTORIES - MAKE THEM PROPER
      task = create(:task, :medium_priority, title: 'create erd diagram', project: project, commenter: owner, creator: owner)
      create(:attachment, attachment_file_name: 'awesome_project_attachment.jpg', attachment_content_type: 'image/jpeg', attachable: project)
      create(:attachment, attachment_file_name: 'non_project_attachment.jpg', attachment_content_type: 'image/jpeg', attachable: task)

      visit project_attachments_path(project)

      expect(page).to have_content('awesome_project_attachment.jpg')
      expect(page).not_to have_content('non_project_attachment.jpg')
    end
  end

  context 'when creating task, comment or discussion with attachment, and we allow user to show attached file on attachments page' do
    it 'shows allowed task attachment on attachments page', js: true do
      visit project_tasks_path(project)

      fill_in 'task[title]', with: 'create entity relationship diagram'
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_project_attachment.jpg'))
      find('input[name="add_files_to_project"]').click
      find('input[name="commit"]').click

      visit project_attachments_path(project)

      expect(page).to have_content('awesome_project_attachment.jpg')
      expect(page).to have_content(owner.name)
    end

    it 'shows allowed comment attachment on attachments page', js: true do
      task = create(:task, :low_priority, title: 'create flow chart', project: project, commenter: owner, creator: owner)
      visit project_task_path(project, task)

      execute_script('$("#comment_content").trumbowyg("html", "also mentioned your name & roll no.");')
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_project_attachment.jpg'))
      find('input[name="add_files_to_project"]').click
      find('input[name="commit"]').click

      visit project_attachments_path(project)

      expect(page).to have_content('awesome_project_attachment.jpg')
      expect(page).to have_content(owner.name)
    end

    it 'shows allowed discussion attachment on attachments page', pending: 'ActionController::InvalidAuthenticityToken, js: true' do
      visit project_discussions_path(project)
      find('a[data-target="#discussion"]').click
      fill_in 'discussion_title', with: 'which tool should be used for accounts'

      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_project_attachment.jpg'))
      find('input[name="add_files_to_project"]').click
      find('input[name="commit"]').click
      # save_and_open_page
      # save_and_open_screenshot
      visit project_attachments_path(project)

      expect(page).to have_content('awesome_project_attachment.jpg')
      expect(page).to have_content(owner.name)
    end
  end

  context 'when discussion' do
    let!(:discussion) { create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner) }

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
    let!(:task) { create(:task, :medium_priority, title: 'create erd diagram', project: project, commenter: owner, creator: owner) }

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
