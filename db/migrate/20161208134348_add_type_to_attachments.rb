class AddTypeToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :type, :string

    Attachment.where(attachable_type: 'Project').update_all(type: 'ProjectAttachment')
  end
end
