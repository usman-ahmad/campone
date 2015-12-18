class User < ActiveRecord::Base
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates :name, presence: true

  has_many :projects, foreign_key: :owner_id
  has_many :contributions
  has_many :shared_projects, through: :contribution, source: :project
  has_many :user_discussions
  has_many :discussions, through: :user_discussions
  has_many :assigned_tasks, class_name: Task, foreign_key: :assigned_to
  has_many :notifications

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


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
end
