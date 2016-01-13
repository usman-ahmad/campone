class ChangeEnumToStringForPriorityAndProgress < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.change :priority, :string, default: 'None'
      t.change :progress, :string, default: 'No progress'
    end

    Task.reset_column_information

    priority = { nil=> 'None', '0' => 'Low', '1' => 'Medium', '2' => 'High' }
    progress = { '0' => 'No progress', '1' => 'In progress', '2' => 'Completed' }

    Task.find_each do |task|
      task.priority = priority[task.priority]
      task.progress = progress[task.progress]
      task.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
