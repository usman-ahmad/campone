require 'rails_helper'

describe 'tasks management', type: :feature do
  let!(:owner) { create(:user, name: 'Great Person') }
  let!(:task_owner) { create(:user, name: 'dev team') }
  let!(:project) { create(:project, owner: owner) }
  let!(:task) { create(:task, title: 'bring bread with eggs', priority: 'Medium', progress: 'unstarted', project: project, creator: task_owner) }

  before do
    login(owner.email, 'secret_password')
  end

  describe 'ToDo List' do
    before do
      visit project_tasks_path(project)
    end

    it 'should show in ToDo list' do
      expect(page).to have_css('ul#tasks li', count: 1)
      expect(page).to have_content('bring bread with eggs')
    end

    it 'allow to edit from todo list' do
      find('li', text: 'bring bread with eggs').click
      click_on 'Edit'
      fill_in 'task[title]', with: 'bring blackcurrant jam also'

      click_button 'Update To-Do'

      expect(page).to have_content('bring blackcurrant jam also')
      expect(page.current_path).to eq project_task_path(project, task)
    end

    it 'allow to delete from todo list', js: true, driver: :selenium do
      find('li', text: 'bring bread with eggs').find('.fa-trash-o').click
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_css('.ui-sortable li', :count => 0)
    end
  end

  describe 'show/hide completed tasks' do
    let!(:completed_task) { create(:task, title: 'completed my breakfast', progress: 'finished', project: project, creator: owner) }

    before do
      visit project_tasks_path(project)
    end

    it 'hides completed tasks', pending: 'feature has been redesigned or removed' do
      expect(page).to have_css('ul#tasks li', :count => 1)
      expect(page).to_not have_content('completed my breakfast')
    end

    it 'shows completed tasks', pending: 'feature has been redesigned or removed' do
      click_on 'Show Completed Task'
      expect(page).to have_css('ul#tasks li', :count => 2)
      expect(find('li', text: completed_task.title)).to have_content('finished')
      expect(find('li', text: task.title)).to have_content('unscheduled')
    end
  end

  describe 'Create' do
    before { visit new_project_task_path(project) }

    it 'creates new task when only title is provided' do
      fill_in 'task[title]', with: 'kindly make an awesome cup of tea'
      click_button 'Add To-Do'
      expect(page).to have_content('successfully created')
      expect(page).to have_content('kindly make an awesome cup of tea')
    end

    it 'would not create task without a title' do
      click_button 'Add To-Do'
      expect(page).to have_content('error')
    end

    # Its better to test single field in one example but for performance we can test many things in one
    it 'assigns correct values', js: true do
      fill_in 'task[title]', with: 'bring some thing with tea'

      execute_script('$(".description-textarea").trumbowyg("html", "bring some date biscuits with some salty stuff");')
      fill_in 'task[due_at]', with: '2016-03-30' # Datepicker

      select 'High', :from => 'Priority'
      select 'Everybody', :from => 'Assigned to'

      click_button 'Add To-Do'
      expect(page).to have_content('2016-03-30')

      click_link 'bring some thing with tea'

      expect(page).to have_content('bring some thing with tea')
      expect(page).to have_content('bring some date biscuits with some salty stuff')
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
      expect(page.find('span[id="assigned_to"]')).to have_content(owner.name)
    end

    it 'should change progress', js: true do
      click_on 'Assign to Me'
      click_on 'start'
      expect(page).to have_content('Assigned To: Great Person')
      expect(page.find('span[id="progress"]')).to have_content('Started')
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
