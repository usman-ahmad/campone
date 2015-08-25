class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.references :project, index: true, foreign_key: true
      t.integer :priority
      t.date :due_at

      t.timestamps null: false
    end
  end
end
