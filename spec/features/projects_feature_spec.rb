require 'rails_helper'

describe 'projects management', type: :feature do
  let!(:owner) { create(:user) }
  let!(:project) { create(:project, owner: owner) }

  before do
    login(owner.email, 'secretpassword')
  end

  describe 'creating a new project' do
    it 'should create project' do
      click_on('Create New Project')

      fill_in 'project_name',        with: 'camp one'
      fill_in 'project_description', with: 'it should be completed within 3 months'

      click_button 'Create Project'
      expect(page).to have_content('it should be completed within 3 months')
    end
  end

  describe 'editing an existing project' do
    before do
      visit edit_project_path(project)
    end

    it 'should edit project' do
      fill_in 'project_name',        with: 'camp one teknuk'
      fill_in 'project_description', with: 'This project will create teknuk team'

      click_button 'Update Project'

      expect(page).to have_content('Project was successfully updated.')
      expect(page).to have_content('camp one teknuk')
      expect(page).to have_content('This project will create teknuk team')
    end

    it 'should display in dashboard' do
      visit projects_path
      expect(page.current_path).to eq projects_path
      expect(find(:css, 'div.project')).to have_content(project.name)
    end
  end

  def check_fields
    expect(page).to have_content('Name:')
    expect(page).to have_content('camp one')
    expect(page).to have_content('Description:')
    expect(page).to have_content('it should be create within 3 months')
    expect(page).to have_content('Owner:')
  end
end
