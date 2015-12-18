require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can be build' do
    build(:user).should be_valid
  end

  it 'cannot build users with same email' do
   first_user =  create(:user)
   build(:user, email: first_user.email).should_not be_valid
  end

  it 'should generate new authentication_token' do
    user = build(:user)
    authentication_token_before = user.authentication_token
    user.update_attributes(authentication_token:nil)
    user.authentication_token.should_not eq(authentication_token_before)
  end

  it 'validates name is present' do
    build(:user, name:nil).should_not be_valid
  end

end
