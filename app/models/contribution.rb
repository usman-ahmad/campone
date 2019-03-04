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

  before_validation :invite_and_set_user_and_set_initials
  before_create :generate_token
  before_create :set_position

  validates :initials,
            uniqueness: {scope: [:project_id], case_sensitive: false},
            length: 2..4

  scope :joined, -> {where(status: 'joined')}

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
    if user.invitation_accepted? # UA[2019/02/26] user.accepted_or_not_invited? does not make sense for resend_invitation
      UserMailer.contribution_mail(self).deliver
    else
      user.invite!(inviter, invite_by_devise_options(user.name, user.email))
    end
  end

  def email
    user.try(:email)
  end

  private

  def invite_and_set_user_and_set_initials
    user = User.find_by(email: email)
    # TODO: Refactor, Do not send invite if contribution is not valid ... https://stackoverflow.com/questions/1242617/rails-partial-table-validations
    user ||= User.invite!({email: email, name: name}, inviter, invite_by_devise_options(name, email))
    self.user = user if user.persisted?
    set_initials
  end

  def invite_by_devise_options(name, email)
    # TODO: RECHECK and Make the use of I18n and locale files proper
    {
        name_or_email: name || email,
        project_title: project.title,
        inviter_name: inviter.name,
        subject: I18n.t('devise.mailer.invitation_instructions.subject',
                        inviter_name: inviter.name, project_title: project.title)
    }
  end

  def set_initials
    return if self.initials.present?
    source = self.user.name || self.user.email
    name_initials = source.split(' ').map {|x| x[0]}.join()[0..1].upcase
    postfix = name_initials.length.equal?(1) ? 1 : ''
    while self.project.contributions.exists?(initials: "#{name_initials}#{postfix}") do
      postfix = (postfix || 0) + 1
    end
    self.initials = "#{name_initials}#{postfix}".upcase
  end

  def generate_token
    self.token = "#{project.friendly_id}-#{SecureRandom.hex(15).encode('UTF-8')}"
  end

  def set_position
    self.position = self.user.projects.maximum(:position) ? self.user.projects.maximum(:position) + 1 : 1
  end
end
