class Invitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  enum role: [ :organizer, :team_player, :contributor ]
end
