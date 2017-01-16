class UpdateOwnerIdZeroToNilInTasks < ActiveRecord::Migration[5.0]
  def up
    Task.where(:owner_id => 0).update_all(:owner_id => nil)
  end

  def down
    Task.where(:owner_id => nil).update_all(:owner_id => 0)
  end
end
