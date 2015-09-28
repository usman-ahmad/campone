class AddProgressToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :progress, :integer, default: 0
  end
end
