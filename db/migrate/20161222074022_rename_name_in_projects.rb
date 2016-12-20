class RenameNameInProjects < ActiveRecord::Migration[5.0]
  def change
    rename_column :projects, :name, :title
  end
end
