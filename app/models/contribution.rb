# == Schema Information
#
# Table name: contributions
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token      :string
#  status     :string           default("pending")
#  inviter_id :integer
#

class Contribution < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :inviter, class_name: 'User'

  attr_accessor :email

  before_validation :invite_and_set_user
  before_create :generate_token

  ROLES = {
      manager: 'Manager',
      member: 'Member',
      guest: 'Guest',
      owner: 'Owner',
  }

  STATUSES = %w(pending joined)

  validates :user, presence: {message: 'not created. Check your email.'},
            uniqueness: {scope: :project, message: 'Already invited on this project.'}
  validates :role, inclusion: {in: ROLES.values}
  validates :status, inclusion: {in: STATUSES}

  def resend_invitation
    if user.accepted_or_not_invited?
      UserMailer.contribution_mail(self).deliver
    else
      invite(user.email)
    end
  end

  def email
    user.try(:email)
  end

  private

  def invite_and_set_user
    user = User.where(email: @email).first

    # TODO: Refactor, Do not send invite if contribution is not valid
    unless user
      user = invite(@email)
    end

    self.user = user if user.persisted?
  end

  def invite(email)
    # puts "*********inviter #{inviter}"
    User.invite!({email: email}, inviter)
  end

  def generate_token
    self.token = "#{project.friendly_id}-#{SecureRandom.hex(15).encode('UTF-8')}"
  end
end
