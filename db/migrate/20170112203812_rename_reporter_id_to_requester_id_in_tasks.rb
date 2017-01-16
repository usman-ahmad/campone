class RenameReporterIdToRequesterIdInTasks < ActiveRecord::Migration[5.0]
  def change
    rename_column :tasks, :reporter_id, :requester_id
  end
end
