class ChangeEnumToStringForPriorityAndProgress < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.change :priority, :string, default: 'None'
      t.change :progress, :string, default: 'No progress'
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
