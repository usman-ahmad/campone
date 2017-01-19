class RenameTaskToStory < ActiveRecord::Migration[5.0]
  def up
    rename_table :tasks, :stories
    rename_column :stories, :task_type, :story_type
    Attachment.where(attachable_type: 'Task').update_all(attachable_type: 'Story')
    Comment.where(commentable_type: 'Task').update_all(commentable_type: 'Story')
    Notification.where(notifiable_type: 'Task').update_all(notifiable_type: 'Story')
  end

  def down
    Notification.where(notifiable_type: 'Story').update_all(notifiable_type: 'Task')
    Comment.where(commentable_type: 'Story').update_all(commentable_type: 'Task')
    Attachment.where(attachable_type: 'Story').update_all(attachable_type: 'Task')
    rename_column :stories, :story_type, :task_type
    rename_table :stories, :tasks
  end
end
