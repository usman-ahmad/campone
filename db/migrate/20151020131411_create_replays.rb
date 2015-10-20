class CreateReplays < ActiveRecord::Migration
  def change
    create_table :replays do |t|
      t.string :content
      t.integer :user_id
      t.integer :comment_id

      t.timestamps null: false
    end
  end
end
