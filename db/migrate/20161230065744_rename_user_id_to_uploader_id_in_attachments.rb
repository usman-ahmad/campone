class RenameUserIdToUploaderIdInAttachments < ActiveRecord::Migration[5.0]
  def change
    rename_column :attachments, :user_id, :uploader_id
    add_index :attachments, :uploader_id
    add_foreign_key :attachments, :users, column: :uploader_id
  end
end
