class AddProjectAndCreatorToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :project, index: true, foreign_key: true
    add_column :groups, :creator_id, :integer, index: true
  end
end
