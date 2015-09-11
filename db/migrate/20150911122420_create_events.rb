class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.date :due_at
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
