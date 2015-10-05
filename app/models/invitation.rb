class Invitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates :user, uniqueness: { scope: :project, message: "Alredy invited on this project." }
  enum role: [ :organizer, :team_player, :contributor ]
end
