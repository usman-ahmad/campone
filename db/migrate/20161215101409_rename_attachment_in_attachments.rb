class RenameAttachmentInAttachments < ActiveRecord::Migration[5.0]
  OLD_DIRECTORY = Rails.root.join('public/system/attachments/attachments')
  NEW_DIRECTORY = Rails.root.join('public/system/attachments/documents')

  def up
    rename_column :attachments, :attachment_file_name, :document_file_name
    rename_column :attachments, :attachment_file_size, :document_file_size
    rename_column :attachments, :attachment_updated_at, :document_updated_at
    rename_column :attachments, :attachment_content_type, :document_content_type

    FileUtils.mv(OLD_DIRECTORY, NEW_DIRECTORY) if File.exist?(OLD_DIRECTORY)
  end

  def down
    rename_column :attachments, :document_file_name, :attachment_file_name
    rename_column :attachments, :document_file_size, :attachment_file_size
    rename_column :attachments, :document_updated_at, :attachment_updated_at
    rename_column :attachments, :document_content_type, :attachment_content_type

    FileUtils.mv(NEW_DIRECTORY, OLD_DIRECTORY) if File.exist?(NEW_DIRECTORY)
  end
end
