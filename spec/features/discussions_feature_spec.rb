require 'rails_helper'

describe 'discussions management', type: :feature do
  let!(:owner) { create(:user, name: 'sunny') }
  let!(:project) { create(:project, owner: owner) }
  let!(:discussion) {create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner)}

  before do
    login(owner.email, 'secretpassword')
  end

  context 'Discussion List' do
    before do
      visit project_discussions_path(project)
    end
    it 'should show in Discussion List' do
      find('table.discussion-list > tbody tr', :count => 1)
      expect(find('table.discussion-list > tbody tr')).to have_content('how to deliver')
    end

    it 'should show posted by' do
      expect(find('table.discussion-list > tbody tr')).to have_content('sunny')
    end

    it 'should open discussion on click', js: true, driver: :selenium do
      find('table.discussion-list > tbody tr:nth-child(1)').click
      expect(page.current_path).to eq project_discussion_path(project, discussion)
    end
  end

  context 'Create Discussion' do
    before do
      visit project_discussions_path(project)
    end

    # TODO: When editor selection is final, then handle this test case
    it 'creates a discussion', pending: 'discussion content access issue'  do
      fill_in 'discussion_title', with: 'how to deliver notifications'
      fill_in 'discussion_content', with: 'discussion about how to deliver notifications'
      click_on 'Create Discussion'
      expect(page).to have_content('how to deliver notifications')
      expect(page).to have_content('discussion about how to deliver notifications')
    end
  end

  context 'update' do
    before do
     visit project_discussion_path(project, discussion)
    end
    it 'should update title' do
      expect(page).to have_content('how to deliver')
      find('a', text: 'Edit').click
      fill_in 'discussion_title', with: 'how to implement'
      # find('input[name="commit"]').click
      click_on 'Update Discussion'
      expect(page).to have_content('how to implement')
    end
  end

  context 'when edit delete and navigate from discussion' do
    before do
      visit project_discussion_path(project,discussion)
    end
    it 'should edit' do
      find('a', text: 'Edit').click
      sleep(2)
      expect(page.current_path).to eq edit_project_discussion_path(project, discussion)
    end

    it 'should navigate to Discussion List', pending: 'feature has been redesigned or removed' do
      find('a', text: 'List all Discussions').click
      sleep(2)
      expect(page.current_path).to eq project_discussions_path(project)
    end

    it 'should navigate to new discussion', pending: 'feature has been redesigned or removed' do
      find('a', text: 'Start New Discussion').click
      sleep(2)
      expect(page.current_path).to eq new_project_discussion_path(project)
    end

    it 'should delete', :js => true, driver: :selenium do
      find('a', text: 'Delete').click
      page.driver.browser.switch_to.alert.accept
      sleep(2)
      expect(page.current_path).to eq project_discussions_path(project)
    end
  end

  # TO DO
  # context 'when attachment' do
  #   it 'should attach with new disucssion and download from discussion page' do
  #
  #   end
  #
  #   it 'should allow to attach from edit and download from discussion page' do
  #
  #   end
  # end

  # TO DO
  # context 'share with other users' do
  #   it 'should be private' do
  #
  #   end
  #
  #   it 'should be able to share with other users when its not private' do
  #
  #   end
  # end
end
