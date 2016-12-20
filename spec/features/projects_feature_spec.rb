require 'rails_helper'

describe 'projects management', type: :feature do
  let!(:owner) { create(:user) }
  let!(:project) { create(:project, owner: owner) }

  before do
    login(owner.email, 'secret_password')
  end

  describe 'creating a new project' do
    it 'should create project' do
      click_on('Create New Project')

      fill_in 'project_title', with: 'sunday morning get together'
      fill_in 'project_description', with: 'contact with friends and invite them for some desi breakfast'

      click_button 'Create Project'
      expect(page).to have_content('contact with friends and invite them for some desi breakfast')
    end
  end

  describe 'editing an existing project' do
    before do
      visit edit_project_path(project)
    end

    it 'should edit project' do
      fill_in 'project_title', with: 'saturday morning get together'
      fill_in 'project_description', with: 'contact with friends at formal and informal level for desi breakfast'

      click_button 'Update Project'

      expect(page).to have_content('Project was successfully updated.')
      expect(page).to have_content('saturday morning get together')
      expect(page).to have_content('contact with friends at formal and informal level for desi breakfast')
    end

    it 'should display in dashboard' do
      visit projects_path
      expect(page.current_path).to eq projects_path
      result = page.all('h3.project-title')
      expect(result.map(&:text)).to have_content(project.title)
    end
  end
end
