require 'rails_helper'

describe 'tasks management', type: :feature do
  let!(:owner)   { create(:user) }
  let!(:project) { create(:project, owner: owner) }
  let!(:task)    { create(:medium_priority_task, title: 'create erd diagram',project: project , commenter: owner, creator: owner)}

  before do
    login(owner.email, 'secretpassword')
  end

  describe 'ToDo List' do
    before do
      visit project_tasks_path(project)
    end

    it 'should show in ToDo list' do
      expect(page).to have_css('ul#tasks li', count: 1)
      expect(page).to have_content('create erd diagram')
    end

    it 'allow to edit from todo list' do
      find('li', text: 'create erd diagram').click
      click_on 'Edit'
      fill_in 'task_title', with: 'create erd diagram and implement'

      click_button 'Update Task'

      expect(page).to have_content('create erd diagram')
      expect(page.current_path).to eq project_task_path(project, task)
    end

    it 'allow to delete from todo list', js: true, driver: :selenium do
      find('li', text: 'create erd diagram').find('.fa-trash-o').click
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_css(".ui-sortable li", :count => 0)
    end
  end

  describe 'show/hide completed tasks' do
    let!(:completed_task) { create(:task, title: 'A completed task', progress: 'Completed', project: project, creator: owner ) }

    before do
      visit project_tasks_path(project)
    end

    it 'hides completed tasks' do
      expect(page).to     have_css("ul#tasks li", :count => 1)
      expect(page).to_not have_content('A completed task')
    end

    it 'shows completed tasks' do
      click_on 'Show Completed Tasks'
      expect(page).to have_css("ul#tasks li", :count => 2)
      expect(find('li', text: completed_task.title)).to have_content('Completed')
      expect(find('li', text: task.title)).to have_content('No progress')
    end
  end

  describe 'Create' do
    before { visit new_project_task_path(project) }

    it 'creates new task when only title is provided' do
      fill_in 'Title', with: 'create erd diagram and implement'
      click_button 'Create Task'
      expect(page).to have_content("successfully created")
      expect(page).to have_content("create erd diagram and implement")
    end

    it 'would not create task without a title' do
      click_button 'Create Task'
      expect(page).to have_content("error")
    end

    # Its better to test single field in one example but for performance we can test many things in one
    it 'assigns correct values' do
      fill_in 'Title', with: 'create erd diagram and implement'
      fill_in 'Description', with: 'Use Microsoft Visio to create ERD'
      fill_in 'Due at', with: '2016-03-30' # Datepicker

      select 'High', :from => 'Priority'
      select 'Everybody', :from => 'Assigned to'

      click_button 'Create Task'

      expect(page).to have_content('create erd diagram and implement')
      expect(page).to have_content('Use Microsoft Visio to create ERD')
      expect(page).to have_content('2016-03-30')

      expect(page).to have_content('High')
      expect(page).to have_content('Everybody')
    end
  end

  describe 'Update', js: true do
    before do
      visit project_task_path(project, task)
    end

    it 'should assign to me' do
      click_on 'Assign to Me'
      expect(page).to have_content(owner.name)
    end

    it 'should change progress' do
      click_on 'Assign to Me'
      click_on 'Start'
      expect(page).to have_content('Started')
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
end
