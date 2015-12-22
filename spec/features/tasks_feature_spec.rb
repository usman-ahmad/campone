require 'rails_helper'

describe 'tasks management', type: :feature, :js => true do
  before do
    user = create_admin_user_and_login
    @project = create(:project, owner: user)
    visit project_tasks_path(@project)
  end
  context 'ToDo List' do
    before do
      visit project_tasks_path(@project)
      find('a', text: 'New Task').click
      page.find(:css, ".newgroup_icon").click
      fill_in 'task_task_group_attributes_name', with: 'ruby'
      fill_in 'task_title', with: 'create erd diagram'
      fill_in 'task_description', with: 'it should be complete on time'
      within '#task_priority' do
        find('option[value="medium"]').click
      end
      within '#task_assigned_to' do
        find('option[value="0"]').click
      end
      find('input[name="commit"]').click
    end

    it 'should show in ToDo list' do
      visit project_tasks_path(@project)
      page.should have_css(".ui-sortable li", :count => 1)
      find(".ui-sortable li").should have_content('create erd diagram')
    end
    it 'allow to edit from todo list' do
      visit project_tasks_path(@project)
      find('ul#sortable li div.pull-right a:nth-child(1)').click
      fill_in 'task_title', with: 'create erd diagram and implement'
      find('input[name="commit"]').click
      find(:css, 'div.todo-name').should have_content('create erd diagram and implement')
      expect(page.current_path).to eq project_task_path(@project, id: 1)
    end
    it 'allow to delete from todo list' do
      visit project_tasks_path(@project)
      find('ul#sortable li div.pull-right a:nth-child(2)').click
      page.driver.browser.switch_to.alert.accept
      page.should have_css(".ui-sortable li", :count => 0)
    end
  end


  context 'show/hide completed tasks' do
    before do
      # change progress to completed
      visit project_tasks_path(@project)
      create_task
      visit project_tasks_path(@project)
      find('ul#sortable li div.pull-right a:nth-child(1)').click
      within '#task_progress' do
        find('option[value="completed"]').click
      end
      find('input[name="commit"]').click

      # create second task with no_progress
      visit project_tasks_path(@project)
      create_task
      visit project_tasks_path(@project)
    end
    it 'should show' do
      find('a', text: 'Show Completed Tasks').click
      page.should have_css(".ui-sortable li", :count => 2)
      page.find(".ui-sortable li:nth-child(1)").should have_content('No progress')
      page.find(".ui-sortable li:nth-child(2)").should have_content('Completed')
    end
    it 'should hide' do
      page.should have_css(".ui-sortable li", :count => 1)
      page.find(".ui-sortable li:nth-child(1)").should have_content('No progress')
    end
  end

  context 'when associated with group' do
    before do
      visit project_tasks_path(@project)
      create_task
    end
    it 'should be assign with group' do
      find('ul.todo-info-list li:nth-child(1)').should have_content('ruby')
    end
  end


  context 'update' do
    before do
      visit project_tasks_path(@project)
      create_task
    end
    it 'should assign to me' do
      find('a', text:'Assign to Me').click
      find('ul.todo-info-list li:nth-child(2)').should have_content('sunny')
    end
    it 'should change progress' do
      find('a', text:'Assign to Me').click
      find('a', text:'Start Progress').click
      sleep(20)
      find('ul.todo-info-list li:nth-child(4)').should have_content('In progress')
    end
  end
  # TO DO, ckeditor is dont provide find any element with the help of capybara.
  # There is a need to write these tests with another technique
  # context 'comment' do
  #   it 'should allow to create' do
  #
  #   end
  #   it 'should allow to edit' do
  #
  #   end
  #   it 'should allow to delete' do
  #
  #   end
  # end
  def create_task
    find('a', text: 'New Task').click
    page.find(:css, ".newgroup_icon").click
    fill_in 'task_task_group_attributes_name', with: 'ruby'
    fill_in 'task_title', with: 'create erd diagram'
    find('input[name="commit"]').click
  end
end
