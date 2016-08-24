class RemoveProjectGroupIdFromProjects < ActiveRecord::Migration[5.0]
  def change
    remove_column :projects, :project_group_id, :integer
  end
end
