class RenameUserIdToOpenerIdInDiscussions < ActiveRecord::Migration[5.0]
  def change
    rename_column :discussions, :user_id, :opener_id
    add_index :discussions, :opener_id
    add_foreign_key :discussions, :users, column: :opener_id
  end
end
