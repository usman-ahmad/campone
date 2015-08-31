class User < ActiveRecord::Base

  has_many :projects, foreign_key: :owner_id
  has_many :invitations
  has_many :shared_projects, through: :invitations, source: :project
  has_many :user_discussions
  has_many :discussions, through: :user_discussions

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
