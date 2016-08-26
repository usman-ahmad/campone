class Contribution < ApplicationRecord
  belongs_to :project
  belongs_to :user

  ROLES = {
      organizer:   'Organizer',
      team_player: 'Team player',
      contributor: 'Contributor',
      owner:       'Owner',
  }

  validates :user, uniqueness: { scope: :project, message: "Already invited on this project." }
  validates :role, inclusion: { in: ROLES.values }
end
