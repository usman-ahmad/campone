class RenameUserIdToReporterIdInTasks < ActiveRecord::Migration[5.0]
  def change
    rename_column :tasks, :user_id, :reporter_id
    add_index :tasks, :reporter_id
    add_foreign_key :tasks, :users, column: :reporter_id
  end
end
