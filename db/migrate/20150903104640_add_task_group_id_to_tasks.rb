class AddTaskGroupIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :task_group_id, :integer
    add_index  :tasks, :task_group_id
  end
end
