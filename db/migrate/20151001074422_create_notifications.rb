class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :activity, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :status

      t.timestamps null: false
    end
  end
end
