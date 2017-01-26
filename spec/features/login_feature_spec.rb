require 'rails_helper'

describe 'login', type: :feature do
  let(:user) { create(:user) }

  context 'login to dashboard  via root path' do
    before {
      visit root_path
    }

    it 'should be using email', pending: 'feature has to be redesigned' do
      fill_in 'login_user_email', with: user.email
      fill_in 'login_user_password', with: 'secret_password'
      click_button 'Submit'
      expect(page.current_path).to eq projects_path
    end

    it 'should be using username', pending: 'feature has to be redesigned' do
      fill_in 'login_user_email', with: user.username
      fill_in 'login_user_password', with: 'secret_password'
      click_button 'Submit'
      expect(page.current_path).to eq projects_path
    end
  end

  context 'login to dashboard via users path' do
    before {
      visit new_user_session_path
    }

    it 'should be using email' do
      fill_in 'user_login', with: user.email
      fill_in 'user_password', with: 'secret_password'
      click_button 'Sign in'
      expect(page.current_path).to eq projects_path
    end

    it 'should be using username' do
      fill_in 'user_login', with: user.username
      fill_in 'user_password', with: 'secret_password'
      click_button 'Sign in'
      expect(page.current_path).to eq projects_path
    end
  end
end
