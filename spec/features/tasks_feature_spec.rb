require 'rails_helper'

describe 'tasks management', type: :feature, :js => true do
  let!(:owner)   { create(:user) }
  let!(:project) { create(:project, owner: owner) }
  let!(:group)   { create(:task_group, name: 'ruby')}
  let!(:task)    { create(:medium_priority_task, title: 'create erd diagram',project: project , commenter: owner, creator: owner,task_group: group)}

  before do
    login(owner.email, 'secretpassword')
    visit project_tasks_path(project)
  end
  context 'ToDo List' do
    before do
      visit project_task_path(project, task)
    end

    it 'should show in ToDo list' do
      visit project_tasks_path(project)
      page.should have_css(".ui-sortable li", :count => 1)
      find(".ui-sortable li").should have_content('create erd diagram')
    end
    it 'allow to edit from todo list' do
      visit project_tasks_path(project)
      find('li', text: 'create erd diagram').click
      find_link('Edit').click
      fill_in 'task_title', with: 'create erd diagram and implement'
      find('input[name="commit"]').click
      find(:css, 'div.todo-name').should have_content('create erd diagram and implement')
      expect(page.current_path).to eq project_task_path(project, task)
    end
    it 'allow to delete from todo list' do
      visit project_tasks_path(project)
      find('li', text: 'create erd diagram').find('.fa-trash-o').click
      page.driver.browser.switch_to.alert.accept
      page.should have_css(".ui-sortable li", :count => 0)
    end
  end

  context 'show/hide completed tasks' do
    let!(:completed_task) { create(:task, progress: 'Completed', project: project, creator: owner ) }

    before do
      visit project_tasks_path(project)
    end
    it 'should show' do
      find('a', text: 'Show Completed Tasks').click
      page.should have_css(".ui-sortable li", :count => 2)
      find('li', text: completed_task.title).should have_content('Completed')
      find('li', text: task.title).should have_content('No progress')
    end
    it 'should hide' do
      page.should have_css(".ui-sortable li", :count => 1)
    end
  end

  context 'when associated with group' do
    before do
      visit project_task_path(project, task)
    end
    it 'should be assign with group' do
      find('ul.todo-info-list li:nth-child(1)').should have_content('ruby')
    end
  end


  context 'update' do
    before do
      visit project_task_path(project, task)
    end
    it 'should assign to me' do
      find('a', text:'Assign to Me').click
      find('ul.todo-info-list li:nth-child(2)').should have_content(owner.name)
    end
    it 'should change progress' do
      find('a', text:'Assign to Me').click
      find('a', text:'Start').click
      find('ul.todo-info-list li:nth-child(5)').should have_content('Started')
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
