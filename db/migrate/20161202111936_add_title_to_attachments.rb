class AddTitleToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :title, :string
    Attachment.reset_column_information

    Attachment.find_each do |attachment|
      attachment.update_column(:title, attachment.attachment_file_name)
    end
  end
end
