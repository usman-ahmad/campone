require 'rails_helper'

describe 'login', type: :feature, :js => true do
  it 'should login to dashboard' do
    create_admin_user_and_login
  end
end
