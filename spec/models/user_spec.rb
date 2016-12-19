# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  name                   :string
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  authentication_token   :string
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can be build' do
    expect(build(:user)).to be_valid
  end

  it 'cannot build users with same email' do
    first_user = create(:user)
    expect(build(:user, email: first_user.email)).to_not be_valid
  end

  it 'should generate new authentication_token' do
    user = build(:user)
    authentication_token_before = user.authentication_token
    user.update_attributes(authentication_token: nil)
    expect(user.authentication_token).to_not eq(authentication_token_before)
  end

  it 'validates name is present' do
    expect(build(:user, name: nil)).to_not be_valid
  end

end
