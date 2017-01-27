class AddTypeToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :type, :string
    Attachment.reset_column_information

    Attachment.where(attachable_type: 'Project').update_all(type: 'ProjectAttachment')
  end
end
