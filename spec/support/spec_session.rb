module SpecSession
  def login(email, password)
    visit   root_path
    fill_in 'login_user_email',    with: email
    fill_in 'login_user_password', with: password
    click_button 'Submit'
  end

  def create_admin_user_and_login
    user = create(:user)
    login(user.email, 'secretpassword')
    user
  end
end
