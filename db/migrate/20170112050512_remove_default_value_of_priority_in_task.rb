class Task < ApplicationRecord
end

class RemoveDefaultValueOfPriorityInTask < ActiveRecord::Migration[5.0]
  def up
    change_column_default(:tasks, :priority, nil)
    Task.where(priority: 'None').update_all(priority: nil)
  end

  def down
    change_column_default(:tasks, :priority, 'None')
    Task.where(priority: nil).update_all(priority: 'None')
  end
end
