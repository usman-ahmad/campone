class RemoveTaskGroupIdFromTasks < ActiveRecord::Migration[5.0]
  def change
    remove_index  :tasks, :task_group_id
    remove_column :tasks, :task_group_id, :integer
  end
end
