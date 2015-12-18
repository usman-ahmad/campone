class RenameInvitationsToContributions < ActiveRecord::Migration
  def change
    rename_table :invitations, :contributions
  end
end
