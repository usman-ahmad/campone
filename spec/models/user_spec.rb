require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can be build' do
    expect(build(:user)).to be_valid
  end

  it 'cannot build users with same email' do
   first_user =  create(:user)
   expect(build(:user, email: first_user.email)).to_not be_valid
  end

  it 'should generate new authentication_token' do
    user = build(:user)
    authentication_token_before = user.authentication_token
    user.update_attributes(authentication_token:nil)
    expect(user.authentication_token).to_not eq(authentication_token_before)
  end

  it 'validates name is present' do
    expect(build(:user, name:nil)).to_not be_valid
  end

end
