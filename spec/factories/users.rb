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
#  deleted_at             :datetime
#  username               :string
#

FactoryGirl.define do
  names = ['user one', 'user two', 'user three']
  usernames = ['kind_man', 'great_man', 'idle_man']

  factory :user do
    sequence(:name) { |n| names[n % 3] }
    sequence(:username) { |n| usernames[n % 3] + n.to_s }
    sequence(:email) { |n| "#{names[n % 3].gsub(' ', '_')}_#{n}@teknuk.com" }
    password 'secret_password'
    password_confirmation 'secret_password'
  end
end
