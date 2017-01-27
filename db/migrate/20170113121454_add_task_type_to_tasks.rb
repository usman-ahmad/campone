class Task < ApplicationRecord
end

class AddTaskTypeToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :task_type, :string, :default => 'feature'
    Task.reset_column_information
    Task.update_all(task_type: 'feature')
  end
end
