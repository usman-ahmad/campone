require 'rails_helper'

# UA[2016/12/01] - TODO - REFACTOR FEATURE SPECS - WHAT IS THE FEATURE HERE - WHAT ARE THE SCENARIOS
# https://www.relishapp.com/rspec/rspec-rails/docs/feature-specs/feature-spec
# https://github.com/eliotsykes/rspec-rails-examples

describe 'Attachments feature for Projects, Stories and Discussions', type: :feature do
  let!(:owner) { create(:user, name: 'Gul Baz Khan', email: 'u@co.co', password: 'some_password', password_confirmation: 'some_password') }
  let!(:project) { create(:project, owner: owner) }

  before do
    login_as(owner, :scope => :user)
    # login('u@co.co', 'some_password')
  end

  context 'on files tab when there is project with no attachments' do
    it 'uploads attachment with title & description' do
      visit project_attachments_path(project)

      fill_in 'Title', with: 'Title of my awesome upload!'
      fill_in 'Description', with: 'Some basic description from client.'
      page.attach_file('attachment[document]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
      click_button 'Create Attachment'

      expect(page).to have_content('Title of my awesome upload!')
      click_link 'Title of my awesome upload!' # GO TO SHOW ATTACHMENT ACTION

      expect(page).to have_content('Title: Title of my awesome upload!')
      expect(page).to have_content('Description: Some basic description from client.')
      expect(page).to have_content('File Name: test_attachment.jpg')
    end

    it 'updates the newly created attachment' do

      create(:project_attachment, title: 'consectetur adipiscing elit', document: File.new('spec/files/awesome_project_attachment.jpg'), uploader: owner, attachable: project)

      visit project_attachments_path(project)

      click_link 'consectetur adipiscing elit'
      click_link 'Edit'

      fill_in 'Title', with: 'consectetur adipiscing'
      fill_in 'Description', with: 'Excepteur sint non proident'
      fill_in 'Attachment name', with: 'new name attachment'

      click_button 'Update Attachment'

      expect(page).to have_content('Title: consectetur adipiscing')
      expect(page).to have_content('File Name: new name attachment')
      expect(page).to have_content('Description: Excepteur sint non proident')
    end

    it 'downloads attachment attached to a project' do
      create(:project_attachment, title: 'the awesome project attachment', document: File.new('spec/files/awesome_project_attachment.jpg'), uploader: owner, attachable: project)
      visit project_attachments_path(project)

      find('tr', text: 'the awesome project attachment').click_link('Download')

      expect(response_headers['Content-Type']).to eq 'image/jpeg'
      expect(response_headers['Content-Disposition']).to eq 'attachment; filename="awesome_project_attachment.jpg"'
    end
  end

  context 'when there is project with existing attachments, and we visit attachments page' do
    it 'enlists project attachment only' do
      # UA[2016/12/01] - TODO - CHECK IF STUBS COULD BE USED
      story = create(:story, project: project, requester: owner)
      create(:project_attachment, title: 'awesome_project_attachment.jpg', document_file_name: 'awesome_project_attachment.jpg', document_content_type: 'image/jpeg', attachable: project, uploader: owner)
      create(:attachment, document_file_name: 'non_project_attachment.jpg', document_content_type: 'image/jpeg', attachable: story, uploader: owner)

      visit project_attachments_path(project)

      expect(page).to have_content('awesome_project_attachment.jpg')
      expect(page).not_to have_content('non_project_attachment.jpg')
    end

    it 'comments on an attachment', js: true do
      create(:project_attachment, title: 'commented attachment here!', document_file_name: 'awesome_project_attachment.jpg', document_content_type: 'image/jpeg', attachable: project, uploader: owner)
      visit project_attachments_path(project)
      click_link 'commented attachment here!'

      sleep(1)
      execute_script('$("#comment_content").trumbowyg("html", "First comment for testing purpose.");')
      click_button 'Create Comment'

      expect(page).to have_content('First comment for testing purpose.')
    end
  end

  context 'on stories listing page, when creating a new story', js: true do
    it 'should display add_files_to_project only when some file is attached' do
      visit project_stories_path(project)

      fill_in 'story[title]', with: 'New Story without attachment'

      expect(page).not_to have_content('also add to Project Files')
      expect(page).not_to have_field('add_files_to_project')

      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_attachment.png'))

      expect(page).to have_content('also add to Project Files')
      expect(page).to have_field('add_files_to_project')
    end

    it 'should add file to project files, when checked add_files_to_project' do
      visit project_stories_path(project)

      fill_in 'story[title]', with: 'New Story with attachment'

      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_attachment.png'))

      check('add_files_to_project')
      click_button('Add To-Do')
      visit project_attachments_path(project)

      expect(page).to have_content('awesome_attachment.png')
      expect(page).to have_content('Uploaded by: Gul Baz Khan')
      click_link 'awesome_attachment.png'

      expect(page).to have_content('Title: awesome_attachment.png')
      expect(page).to have_content('File Name: awesome_attachment.png')
      expect(page).to have_content('Uploaded By: Gul Baz Khan')
    end

    it 'should not add file to project files, when unchecked add_files_to_project' do
      visit project_stories_path(project)

      fill_in 'story[title]', with: 'New Story with attachment'
      page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_attachment.png'))

      uncheck('add_files_to_project')
      click_button('Add To-Do')
      visit project_attachments_path(project)

      expect(page).not_to have_content('awesome_attachment.png')
      expect(page).not_to have_content('Upload By.')
      expect(page).to have_content('No Record Exist')
    end
  end

  # UA[2016/12/07] - TODO - REFACTOR SO THAT SAME TESTS CAN BE REUSED AS THE SCENARIOS ARE SAME WITH VARIATIONS IN PRECONDITIONS
  context 'on STORY SHOW page, when CREATING A COMMENT, and on DISCUSSIONS LISTING page, when ADDING A DISCUSSION' do
    it 'should display add_files_to_project only when some file is attached'
    it 'should add file to project files, when checked add_files_to_project'
    it 'should not add file to project files, when unchecked add_files_to_project'
    # it 'shows allowed comment attachment on attachments page', js: true, driver: :selenium do
    #   story = create(:story, title: 'create flow chart', project: project, commenter: owner, requester: owner)
    #   visit project_story_path(project, story)
    #
    #   execute_script('$("#comment_content").trumbowyg("html", "also mentioned your name & roll no.");')
    #   page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_attachment.png'))
    #   find('input[name="add_files_to_project"]').click
    #   find('input[name="commit"]').click
    #
    #   visit project_attachments_path(project)
    #
    #   expect(page).to have_content('awesome_attachment.png')
    #   expect(page).to have_content(owner.name)
    # end
    #
    # it 'shows allowed discussion attachment on attachments page', js: true, driver: :selenium do
    #
    #   visit project_discussions_path(project)
    #   find('a[data-target="#discussion"]').click
    #   fill_in 'discussion_title', with: 'which tool should be used for accounts'
    #
    #   page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/awesome_attachment.png'))
    #   find('input[name="add_files_to_project"]').click
    #   find('input[name="commit"]').click
    #   visit project_attachments_path(project)
    #
    #   expect(page).to have_content('awesome_attachment.png')
    #   expect(page).to have_content(owner.name)
    # end
  end

  # UA[2016/12/15] - TODO MOVE TO DISCUSSION FEATURE SPECS
  # context 'when discussion', pending: 'REFACTOR OLD SPECS - SEE IF COVERED BY ABOVE SPECS' do
  #   let!(:discussion) { create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner) }
  #
  #   it 'should create discussion with attachment', pending: 'REFACTOR OLD SPECS - SEE IF COVERED BY ABOVE SPECS' do
  #     visit project_discussions_path(project)
  #     fill_in 'discussion_title', with: 'how to deliver'
  #     page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
  #     find('input[name="commit"]').click
  #     page.find_all('img[title= "test_attachment.jpg"]')
  #   end
  #
  #   it 'should attach file when update to discussion', pending: 'REFACTOR OLD SPECS - SEE IF COVERED BY ABOVE SPECS' do
  #     visit project_discussion_path(project, discussion)
  #     find('a', text: 'Edit').click
  #     page.attach_file('attachments_array[]', File.join(Rails.root, '/spec/files/test_attachment.jpg'))
  #     find('input[name="commit"]').click
  #     page.find_all('img[title= "test_attachment.jpg"]')
  #   end
  # end
end
