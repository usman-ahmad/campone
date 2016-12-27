require 'rails_helper'

describe 'discussions management', type: :feature do
  let!(:owner) { create(:user, name: 'Prime Minister') }
  let!(:project) { create(:project, owner: owner) }
  let!(:discussion) { create(:discussion, private: false, title: 'NO discussion on PTI vs PML-N vs PPP', project: project, opener: owner) }

  before do
    login(owner.email, 'secret_password')
  end

  context 'Discussion List' do
    before do
      visit project_discussions_path(project)
    end
    it 'should show in Discussion List' do
      find('table.discussion-list > tbody tr', :count => 1)
      expect(find('table.discussion-list > tbody tr')).to have_content('NO discussion on PTI vs PML-N vs PPP')
    end

    it 'should show opened by' do
      expect(find('table.discussion-list > tbody tr')).to have_content('Prime Minister')
    end

    it 'should open discussion on click', js: true do
      find('table.discussion-list > tbody tr:nth-child(1)').click
      expect(page.current_path).to eq project_discussion_path(project, discussion)
    end
  end

  context 'Create Discussion' do
    before do
      visit project_discussions_path(project)
    end

    it 'creates a discussion', js: true do
      find('a[data-target="#discussion"]').click

      fill_in 'Title', with: 'Upper house vs Lower house.'
      execute_script('$("#discussion_content").trumbowyg("html", "Why lower house is lower than the upper house.");')
      click_button 'Create Discussion'

      find('a', text: 'Upper house vs Lower house.').click

      expect(page).to have_content('Upper house vs Lower house.')
      expect(page).to have_content('Why lower house is lower than the upper house.')
    end
  end

  context 'update' do
    before do
      visit project_discussion_path(project, discussion)
    end
    it 'should update title' do
      expect(page).to have_content('NO discussion on PTI vs PML-N vs PPP')
      find('a', text: 'Edit').click
      fill_in 'discussion_title', with: 'Seriously NO political discussion.'
      # find('input[name="commit"]').click
      click_on 'Update Discussion'
      expect(page).to have_content('Seriously NO political discussion.')
    end
  end

  context 'when edit delete and navigate from discussion' do
    before do
      visit project_discussion_path(project, discussion)
    end
    it 'should edit' do
      find('a', text: 'Edit').click
      sleep(2)
      expect(page.current_path).to eq edit_project_discussion_path(project, discussion)
    end

    # TODO: Feature has been removed
    # RN[2016/12/26]
    # it 'should navigate to Discussion List', pending: 'feature has been redesigned or removed' do
    #   find('a', text: 'List all Discussions').click
    #   sleep(2)
    #   expect(page.current_path).to eq project_discussions_path(project)
    # end
    #
    # it 'should navigate to new discussion', pending: 'feature has been redesigned or removed' do
    #   find('a', text: 'Start New Discussion').click
    #   sleep(2)
    #   expect(page.current_path).to eq new_project_discussion_path(project)
    # end

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
