class AddDeletedToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :is_deleted, :boolean
  end
end
