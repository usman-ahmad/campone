class DropGroupsTable < ActiveRecord::Migration[5.0]
  def up
    remove_index :groups, :type
    drop_table   :groups
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
