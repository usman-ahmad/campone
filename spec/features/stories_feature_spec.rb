require 'rails_helper'

describe 'stories management', type: :feature do
  let!(:owner) { create(:user, name: 'Great Person') }
  let!(:story_owner) { create(:user, name: 'dev team') }
  let!(:project) { create(:project, owner: owner) }
  let!(:story) { create(:story, title: 'bring bread with eggs', priority: 'Medium', state: 'unstarted', project: project, requester: story_owner) }

  before do
    login(owner.email, 'secret_password')
  end

  describe 'ToDo List' do
    before do
      visit project_stories_path(project)
    end

    it 'should show in ToDo list' do
      expect(page).to have_css('ul#stories li', count: 1)
      expect(page).to have_content('bring bread with eggs')
    end

    it 'allow to edit from todo list' do
      find('li', text: 'bring bread with eggs').click
      click_on 'Edit'
      fill_in 'story[title]', with: 'bring blackcurrant jam also'

      click_button 'Update To-Do'

      expect(page).to have_content('bring blackcurrant jam also')
      expect(page.current_path).to eq project_story_path(project, story)
    end

    it 'allow to delete from todo list', js: true, driver: :selenium do
      find('li', text: 'bring bread with eggs').find('.fa-trash-o').click
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_css('.ui-sortable li', :count => 0)
    end
  end

  describe 'show/hide completed stories' do
    let!(:completed_story) { create(:story, title: 'completed my breakfast', state: 'finished', project: project, requester: owner) }

    before do
      visit project_stories_path(project)
    end

    it 'hides completed stories', pending: 'feature has been redesigned or removed' do
      expect(page).to have_css('ul#stories li', :count => 1)
      expect(page).to_not have_content('completed my breakfast')
    end

    it 'shows completed stories', pending: 'feature has been redesigned or removed' do
      click_on 'Show Completed Story'
      expect(page).to have_css('ul#stories li', :count => 2)
      expect(find('li', text: completed_story.title)).to have_content('finished')
      expect(find('li', text: story.title)).to have_content('unscheduled')
    end
  end

  describe 'Create' do
    before { visit new_project_story_path(project) }

    it 'creates new story when only title is provided' do
      fill_in 'story[title]', with: 'kindly make an awesome cup of tea'
      click_button 'Add To-Do'
      expect(page).to have_content('successfully created')
      expect(page).to have_content('kindly make an awesome cup of tea')
    end

    it 'would not create story without a title' do
      click_button 'Add To-Do'
      expect(page).to have_content('error')
    end

    # Its better to test single field in one example but for performance we can test many things in one
    it 'assigns correct values without select story story_type', js: true do
      fill_in 'story[title]', with: 'bring some thing with tea'

      execute_script('$(".description-textarea").trumbowyg("html", "bring some date biscuits with some salty stuff");')
      fill_in 'story[due_at]', with: '2016-03-30' # Datepicker

      select 'High', :from => 'Priority'
      execute_script('$("#story_tag_list").val("STORIES");')
      select 'Great Person', :from => 'Owner'

      click_button 'Add To-Do'
      expect(page).to have_content('2016-03-30')
      expect(page).to have_content('#STORIES')
      click_link 'bring some thing with tea'

      expect(page).to have_content('bring some thing with tea')
      expect(page).to have_content('bring some date biscuits with some salty stuff')
      expect(page).to have_content('High')
      expect(page).to have_content('Great Person')
      expect(page).to have_content('FEATURE')
      expect(page).to have_content('#STORIES')
    end

    it 'creats story with title and single tag', js: true do
      fill_in 'story[title]', with: 'tag my loptop as admin'
      execute_script('$("#story_tag_list").val("ADMIN");')

      click_button 'Add To-Do'
      expect(page).to have_content('#ADMIN')

      click_link 'tag my loptop as admin'
      expect(page).to have_content('#ADMIN')
    end

    it 'creats story with title and multiple tags', js: true do
      fill_in 'story[title]', with: 'tag all office loptops as one two three'
      execute_script('$("#story_tag_list").val("ONE,TWO,THREE,LAB X");')

      click_button 'Add To-Do'
      expect(page).to have_content('#LAB X #THREE #TWO #ONE')

      click_link 'tag all office loptops as one two three'
      expect(page).to have_content('#LAB X #THREE #TWO #ONE')
    end

    it 'assigns correct values with selecting story story_type', js: true do
      fill_in 'story[title]', with: 'bring some thing with tea'
      select 'bug', :from => 'story[story_type]'

      click_button 'Add To-Do'
      click_link 'bring some thing with tea'

      expect(page).to have_content('bring some thing with tea')
      expect(page).to have_content('BUG')
    end
  end

  describe 'Update', js: true do
    before do
      visit project_story_path(project, story)
    end

    it 'should assign to me' do
      click_on 'Assign to Me'
      expect(page.find('span[id="owner"]')).to have_content(owner.name)
    end

    it 'should change state', js: true do
      click_on 'Assign to Me'
      click_on 'start'
      expect(page).to have_content('Owner: Great Person')
      expect(page.find('span[id="state"]')).to have_content('Started')
    end

    it 'should change story story_type' do
      expect(page).to have_content('FEATURE')

      click_on 'Edit'
      select 'bug', :from => 'story[story_type]'

      click_button 'Update To-Do'
      expect(page).to have_content('BUG')
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
