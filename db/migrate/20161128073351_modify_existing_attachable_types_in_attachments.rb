class ModifyExistingAttachableTypesInAttachments < ActiveRecord::Migration[5.0]
  def up
    Attachment.where(:attachable_type => nil).update_all(:attachable_type => 'Project')
  end

  def down
    Attachment.where(:attachable_type => 'Project').update_all(:attachable_type => nil)
  end
end
