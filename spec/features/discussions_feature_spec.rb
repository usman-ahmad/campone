require 'rails_helper'

describe 'discussions management', type: :feature, :js => true do
  let!(:owner) { create(:user) }
  let!(:project) { create(:project, owner: owner) }
  let!(:group) {create(:discussion_group, name: 'diagrams')}
  let!(:discussion) {create(:none_private_discussion, title: 'how to deliver', project: project, commenter: owner, user: owner, discussion_group: group )}

  before do
    login(owner.email, 'secretpassword')
    visit project_discussions_path(project)
  end

  context 'Discussion List' do
    before do
      visit project_discussions_path(project)
    end
    it 'should show in Discussion List' do
      find('table.discussion-list > tbody tr', :count => 1)
      find('table.discussion-list > tbody tr').should have_content('how to deliver')
    end

    it 'should show posted by' do
      find('table.discussion-list > tbody tr').should have_content('sunny')
    end

    it 'should open discussion on click' do
      find('table.discussion-list > tbody tr:nth-child(1)').click
      expect(page.current_path).to eq project_discussion_path(project, id: 1)
    end
  end

  context 'association' do
    before do
      find('a', text: 'New Discussion').click
      fill_in 'discussion_title', with: 'how to deliver'
      fill_in 'discussion_content', with: 'there is a need of discussion about how to deliver notifications'
    end
    it 'should allow to create group' do
      page.find(:css, ".newgroup_icon").click
      fill_in 'discussion_discussion_group_attributes_name', with: 'notifications'
      find('input[name="commit"]').click
      find('ul.todo-info-list li:nth-child(1)').should have_content('notifications')
    end
    it 'should allow to create withouth group' do
      find('input[name="commit"]').click
      find('ul.todo-info-list li:nth-child(1)').should have_content('Not Specified')
    end
  end

  context 'update' do
    before do
     visit project_discussion_path(project, discussion)
    end
    it 'should update title' do
      find('ul.todo-info-list li:nth-child(2)').should have_content('how to deliver')
      find('a', text: 'Edit').click
      fill_in 'discussion_title', with: 'how to implement'
      find('input[name="commit"]').click
      find('ul.todo-info-list li:nth-child(2)').should have_content('how to implement')
    end

    it 'should update group' do
      find('ul.todo-info-list li:nth-child(1)').should have_content('diagrams')
      find('a', text: 'Edit').click
      page.find(:css, ".newgroup_icon").click
      fill_in 'discussion_discussion_group_attributes_name', with: 'notify'
      find('input[name="commit"]').click
      find('ul.todo-info-list li:nth-child(1)').should have_content('notify')
    end

  end

  context 'when edit delete and navigate from discussion' do
    before do
      visit project_discussion_path(project,discussion)
    end
    it 'should edit' do
      find('a', text: 'Edit').click
      sleep(2)
      expect(page.current_path).to eq edit_project_discussion_path(project, id: 1)
    end

    it 'should navigate to Discussion List' do
      find('a', text: 'List all Discussions').click
      sleep(2)
      expect(page.current_path).to eq project_discussions_path(project)

    end

    it 'should navigate to new discussion' do
      find('a', text: 'Start New Discussion').click
      sleep(2)
      expect(page.current_path).to eq new_project_discussion_path(project)
    end

    it 'should delete' do
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
