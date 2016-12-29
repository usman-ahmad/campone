class RenameAssignedToToOwnerIdInTasks < ActiveRecord::Migration[5.0]
  def change
    rename_column :tasks, :assigned_to, :owner_id
    add_index :tasks, :owner_id
    # UA[2017/01/02] - CANNOT ADD FOREIGN_KEY CONSTRAINT AS WE HAVE OWNER_ID(0) FOR "EVERYONE"
    # add_foreign_key :tasks, :users, column: :owner_id
  end
end
