class AddAttachmentGroupIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :attachment_group_id, :integer
  end
end
