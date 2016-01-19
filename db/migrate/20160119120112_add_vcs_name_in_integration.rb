class AddVcsNameInIntegration < ActiveRecord::Migration
  def change
    add_column :integrations, :vcs_name, :string
  end
end
