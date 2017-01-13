class AddPositionToContributions < ActiveRecord::Migration[5.0]
  def up
    add_column :contributions, :position, :integer
    Contribution.reset_column_information
    Contribution.update_all('position = project_id')
  end

  def down
    remove_column :contributions, :position, :integer
  end
end
