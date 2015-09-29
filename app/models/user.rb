class User < ActiveRecord::Base

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  validates :name, presence: true

  has_many :projects, foreign_key: :owner_id
  has_many :invitations
  has_many :shared_projects, through: :invitations, source: :project
  has_many :user_discussions
  has_many :discussions, through: :user_discussions
  has_many :assigned_tasks, class_name: Task, foreign_key: :assigned_to

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
