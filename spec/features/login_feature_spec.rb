require 'rails_helper'

describe 'login', type: :feature, :js => true do
  it 'should login to dashboard' do
    create_admin_user_and_login
  end

  it 'should login to dashboard' do
    visit   root_path
    fill_in 'login_user_email',    with: user.email
    fill_in 'login_user_password', with: "secretpassword"
    click_button 'Submit'
    expect(page.current_path).to eq projects_path
  end
end
