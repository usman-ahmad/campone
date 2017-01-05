class CreateNewNotifications < ActiveRecord::Migration[5.0]
  # rails g migration create_new_notifications receiver:references performer:references content:json notifiable:references{polymorphic} content:json
  def change
    create_table :notifications do |t|
      t.references :receiver, index: true, foreign_key: {to_table: :users}
      t.references :performer, index: true, foreign_key: {to_table: :users}
      t.json :content, default: {}
      t.references :notifiable, index: true, polymorphic: true
      t.boolean :read, default: false
      t.boolean :hidden, default: false

      t.timestamps null: false
    end
  end
end
