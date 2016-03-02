require 'rails_helper'

describe 'projects management', type: :feature, :js => true do
  let!(:owner) { create(:user) }
  let!(:project) { create(:project, owner: owner) }

  before do
    login(owner.email, 'secretpassword')
  end

  describe 'creating a new project' do
    before do
      click_on('Create New Project')
      fill_in 'Name',        with: 'camp one'
      fill_in 'Description', with: 'it should be create within 3 months'
    end

    context 'when group is specified' do
      it 'should create project' do
        find('.newgroup_icon').click
        fill_in 'project_project_group_attributes_name', with: 'ruby'

        click_button 'Create Project'

        expect(page).to have_content 'ruby'
        expect(page).to have_content owner.name

        check_fields
      end
    end

    context 'when group is not specified' do
      it 'should create project' do
        fill_in 'project_name',        with: 'camp one'
        fill_in 'project_description', with: 'it should be create within 3 months'

        click_button 'Create Project'

        expect(page).to have_content 'Not Specified'
        expect(page).to have_content owner.name
      end
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

      page.should have_content('Project was successfully updated.')
      expect(page).to have_content('camp one teknuk')
      expect(page).to have_content('This project will create teknuk team')
    end

    it 'should display in dashboard' do
      visit projects_path
      expect(page.current_path).to eq projects_path
      find(:css, 'div.project').should have_content(project.name)
    end
  end

  def check_fields
    expect(page).to have_content('Group:')
    expect(page).to have_content('Name:')
    expect(page).to have_content('camp one')
    expect(page).to have_content('Description:')
    expect(page).to have_content('it should be create within 3 months')
    expect(page).to have_content('Owner:')
  end
end
