class ModifyRolesOnContributions < ActiveRecord::Migration[5.0]
  # Existing roles
  # ROLES = {
  #     organizer:   'Organizer',
  #     team_player: 'Team player',
  #     contributor: 'Contributor',
  #     owner:       'Owner'
  # }
  #
  # New mapping
  # 'Organizer'   => 'Manager',
  # 'Member'      => 'Member',
  # 'Contributor' => 'Guest'

  def up
    role_map = {
        'Organizer' => 'Manager',
        'Team player' => 'Member',
        'Contributor' => 'Guest'
    }
    Contribution.find_each do |contribution|
      contribution.update_column :role, role_map[contribution.role] if role_map[contribution.role]
    end
  end

  def down
    role_map = {
        'Manager' => 'Organizer',
        'Member' => 'Team player',
        'Guest' => 'Contributor'
    }
    Contribution.find_each do |contribution|
      contribution.update_column :role, role_map[contribution.role] if role_map[contribution.role]
    end
  end
end
