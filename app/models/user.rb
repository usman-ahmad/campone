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

class User < ApplicationRecord
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  validates :name, presence: true

  has_many :contributions
  has_many :projects, through: :contributions, source: :project

  has_many :user_discussions
  has_many :discussions, through: :user_discussions

  has_many :assigned_tasks, class_name: Task, foreign_key: :assigned_to
  has_many :notifications
  has_many :identities, dependent: :destroy

  attr_accessor :existing_email, :existing_password

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # after_create :create_demo_project

  def self.find_for_oauth(auth, signed_in_resource = nil)

    identity = Identity.find_for_oauth(auth)

    # if signed_in_resource(current_user) is provided, this identity will get associated to it.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?
      email = auth.info.email
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
            name: auth.extra.raw_info.name,
            email: email
        )
        user.save!(validate: false)
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def associate_account(existing_email, existing_password)
    user = User.where(email: existing_email).first

    if user && user.valid_password?(existing_password)
      identities.update_all user_id: user
      return user
    end

    self
  end

  def hard_delete
    # TODO: Hard delete contributions and everything else
    projects.destroy_all
  end

  ##################################################################
  #Below enclosed code writen for the purpose of generating authentication token for API
  before_save :ensure_authentication_token

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    endauthenticate_user!
    end
  end
  #################################################################

  # UA[2016/12/18] - DON'T CREATE DEMO_PROJECT FOR EVERY USER - RE_EVALUATE
  # def create_demo_project
  #   demo_data = YAML.load_file('db/demo_project.yml')
  #   project   = Project.create(demo_data['project'].merge(owner: self))
  #   project.tasks.create(demo_data['tasks'])
  # end

end
