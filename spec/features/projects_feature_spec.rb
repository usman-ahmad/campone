require 'rails_helper'

describe 'projects management', type: :feature, :js => true do
  before do
    create_admin_user_and_login
  end

  describe 'creating a new project' do
    before do
      page.find(:css, ".create-project").click
      fill_in 'project_name', with: 'camp one'
      fill_in 'project_description', with: 'it should be create within 3 months'
    end

    context 'when group is specified' do
      it 'should create project' do
        page.find(:css, ".newgroup_icon").click
        fill_in 'project_project_group_attributes_name', with: 'ruby'
        page.find('input[name="commit"]').click
        #this element contain group name
        find(:css, 'dl > dd:nth-child(2)').should have_content('ruby')
        #this element contain project owner name
        find(:css, 'dl > dd:nth-child(8)').should have_content('sunny')
        #other fields of project show page
        check_fields
      end
    end

    context 'when group is not specified' do
      it 'should create project' do
        fill_in 'project_name', with: 'camp one'
        fill_in 'project_description', with: 'it should be create within 3 months'
        page.find('input[name="commit"]').click
        #this element contain group name
        find(:css, 'dl > dd:nth-child(2)').should have_content('Not Specified')
        #this element contain project owner name
        find(:css, 'dl > dd:nth-child(8)').should have_content('asad')
        #other fields of project show page
        check_fields
      end
    end
  end

  describe 'editing an existing project' do
    before do
      page.find(:css, ".create-project").click
      fill_in 'project_name', with: 'camp one'
      fill_in 'project_description', with: 'it should be create within 3 months'
      page.find(:css, ".newgroup_icon").click
      fill_in 'project_project_group_attributes_name', with: 'ruby'
      page.find('input[name="commit"]').click
    end

    it 'should edit project' do
      find('a', text: 'Edit').click
      fill_in 'project_name', with: 'camp one teknuk'
      fill_in 'project_description', with: 'This project will create teknuk team'
      page.find('input[name="commit"]').click
      page.should have_content('Project was successfully updated.')
      find(:css, 'dl > dd:nth-child(4)').should have_content('camp one teknuk')
      find(:css, 'dl > dd:nth-child(6)').should have_content('This project will create teknuk team')
    end

    it 'should display in dashboard' do
      visit projects_path
      expect(page.current_path).to eq projects_path
      find(:css, 'div.project').should have_content('camp one')
    end
  end

  def check_fields
    find(:css, 'dl > dt:nth-child(1)').should have_content('Group:')
    find(:css, 'dl > dt:nth-child(3)').should have_content('Name:')
    find(:css, 'dl > dd:nth-child(4)').should have_content('camp one')
    find(:css, 'dl > dt:nth-child(5)').should have_content('Description:')
    find(:css, 'dl > dd:nth-child(6)').should have_content('it should be create within 3 months')
    find(:css, 'dl > dt:nth-child(7)').should have_content('Owner:')
  end
end
