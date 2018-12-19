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
#  invited_by_type        :string
#  invited_by_id          :integer
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

class User < ApplicationRecord
  has_attached_file :avatar, styles: {medium: '300x300>', thumb: '100x100>'}
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  validates :name, presence: true
  validates :username, presence: true, uniqueness: {case_sensitive: false}
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  before_save :set_username_case

  # TODO: Deactivate User (Update devise) For now we do not allow deleting a user
  # https://github.com/plataformatec/devise/wiki/How-to:-Soft-delete-a-user-when-user-deletes-account
  # What should we do with project of deactivated users?

  # For now commenting out all unused associations
  # Note: We may remove owner_id from project, as we are adding owner role with contributions
  # has_many :owned_projects, class_name: 'Project', foreign_key: :owner_id

  has_many :contributions
  has_many :projects, through: :contributions, source: :project
  # has_many :invited_users, through: :contributions, source: :user, foreign_key: :owner_id

  # has_many :created_stories # which he created on any project
# TODO has_many :assigned_stories => can we rename it?
  has_many :assigned_stories, class_name: Story, foreign_key: :owner_id

  # has_many :started_discussions # started_by this user
  has_many :user_discussions
  has_many :discussions, through: :user_discussions

  # Should we distinguish project_attachments ?
  # has_many :attachments # all attachments either on project, story, discussion or comment
  # has_many :comments

  # has_many :sent_notifications, foreign_key: :actor_id
  has_many :notifications, foreign_key: :receiver_id # received notification
  has_many :identities, dependent: :destroy

  has_one :in_app_notification_setting, dependent: :destroy
  has_one :email_notification_setting, dependent: :destroy

  attr_accessor :existing_email, :existing_password

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # after_create :create_demo_project
  after_create :create_notification_settings

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

  def self.find_for_database_authentication warden_conditions
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", {value: login.strip.downcase}]).first
  end

  def associate_account(existing_email, existing_password)
    user = User.where(email: existing_email).first

    if user && user.valid_password?(existing_password)
      identities.update_all user_id: user
      return user
    end

    self
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  # ensure user account is active
  def active_for_authentication?
    super && !deleted_at
  end

  # provide a custom message for a deleted account
  def inactive_message
    !deleted_at ? super : "You've deleted your account. Contact our support for further help."
  end

  def set_username_case
    self.username = self.username.try(:downcase)
  end

  def hard_delete
    # TODO: Hard delete contributions and everything else,
    # required when a users authenticates via oauth (i-e google)
    # but he wants to associate that account with existing Nimble In account.
    # We'll delete the user created via oauth and link that google account with existing account.
    projects.destroy_all
  end

  ##################################################################
  #Below enclosed code writen for the purpose of generating authentication token for API
  before_save :ensure_authentication_token

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  protected

  # Attempt to find a user by it's email. If a record is found, send new
  # password instructions to it. If not user is found, returns a new user
  # with an email not found error.
  def self.send_reset_password_instructions attributes = {}
    recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end

  def self.find_recoverable_or_initialize_with_errors required_attributes, attributes, error = :invalid
    (case_insensitive_keys || []).each {|k| attributes[k].try(:downcase!)}

    attributes = attributes.slice(*required_attributes)
    attributes.delete_if {|_key, value| value.blank?}

    if attributes.size == required_attributes.size
      if attributes.key?(:login)
        login = attributes.delete(:login)
        record = find_record(login)
      else
        record = where(attributes).first
      end
    end

    unless record
      record = new

      required_attributes.each do |key|
        value = attributes[key]
        record.send("#{key}=", value)
        record.errors.add(key, value.present? ? error : :blank)
      end
    end
    record
  end

  def self.find_record login
    where(["username = :value OR email = :value", {value: login}]).first
  end

  private

  def create_notification_settings
    create_in_app_notification_setting
    create_email_notification_setting
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
      # endauthenticate_user!
    end
  end
  #################################################################

  # UA[2016/12/18] - DON'T CREATE DEMO_PROJECT FOR EVERY USER - RE_EVALUATE
  # def create_demo_project
  #   demo_data = YAML.load_file('db/demo_project.yml')
  #   project   = Project.create(demo_data['project'].merge(owner: self))
  #   project.stories.create(demo_data['stories'])
  # end

end
