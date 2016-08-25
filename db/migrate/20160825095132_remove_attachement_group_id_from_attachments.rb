class RemoveAttachementGroupIdFromAttachments < ActiveRecord::Migration[5.0]
  def change
    remove_column :attachments, :attachment_group_id, :integer
  end
end
