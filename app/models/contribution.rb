class Contribution < ApplicationRecord
  belongs_to :project
  belongs_to :user

  attr_accessor :email

  before_validation :invite_and_set_user

  ROLES = {
      manager: 'Manager',
      member: 'Member',
      guest: 'Guest',
      owner: 'Owner',
  }

  validates :user, presence: {message: 'not created. Check your email.'},
            uniqueness: {scope: :project, message: 'Already invited on this project.'}
  validates :role, inclusion: {in: ROLES.values}

  def resend_invitation
    invite(user.email)
  end

  private

  def invite_and_set_user
    user = User.where(email: @email).first

    unless user
      user = invite(@email)
    end

    self.user = user if user.persisted?
  end

  def invite(email)
    User.invite!(email: email)
  end
end
