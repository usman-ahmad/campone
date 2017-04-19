class CreateNotificationSettings < ActiveRecord::Migration[5.0]
  def up
    create_table :notification_settings do |t|
      t.boolean :new_story
      t.boolean :ownership_change
      t.string :story_state
      t.string :comments
      t.string :commits
      t.boolean :enable
      t.string :type
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end

    User.all.find_each do |user|
      user.send(:create_notification_settings)
    end
  end

  def down
    drop_table :notification_settings
  end
end
