class RenameVcsNameInIntegration < ActiveRecord::Migration
  def change
    rename_column :integrations, :vcs_name, :name
  end
end
