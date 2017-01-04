class RenameActivityAndNotificationTables < ActiveRecord::Migration[5.0]
  def change
    rename_table :activities, :activities_backup
    rename_table :notifications, :notifications_backup
  end
end
