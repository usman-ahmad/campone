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
#  position   :integer
#  initials   :string
#

class Contribution < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :inviter, class_name: 'User'

  attr_accessor :email, :name

  before_validation :invite_and_set_user
  before_validation :set_initials
  before_create :generate_token
  before_create :set_position

  validates :initials,
            uniqueness: {scope: [:project_id], case_sensitive: false, :allow_blank => true},
            length: { maximum: 3 }

  scope :joined, -> { where(status: 'joined') }

  ROLES = {
      guest: 'Guest',
      member: 'Member',
      manager: 'Manager',
      owner: 'Owner',
  }

  STATUSES = %w(pending joined)

  validates :user, presence: {message: 'not created. Please make sure that you have entered a valid email.'},
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
      user = invite_user!
    end

    self.user = user if user.persisted?
  end

  def invite_user!
    opts = {email: @email}
    opts.merge!(name: @name) if name.present?
    User.invite!(opts, inviter)
  end

  def generate_token
    self.token = "#{project.friendly_id}-#{SecureRandom.hex(15).encode('UTF-8')}"
  end

  def set_position
    self.position = self.user.projects.maximum(:position) ? self.user.projects.maximum(:position) + 1 : 1
  end

  def set_initials
    if self.user.try(:name) && !self.initials
      self.initials = user.name.split(' ').collect{|x| x[0]}.join()[0..1].upcase
      count = 1
      current_initials = self.initials
      while self.project.contributions.where(initials: current_initials).present? do
        current_initials="#{self.initials}#{count}"
        count += 1
      end
      self.initials = current_initials
    end

    self.initials = self.initials.upcase if self.initials
  end
end
