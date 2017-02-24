class AddSecureIdToIntegrations < ActiveRecord::Migration[5.0]
  def up
    add_column :integrations, :secure_id, :string
    add_index  :integrations, :secure_id

    Integration.reset_column_information

    Integration.all.find_each do |integration|
      integration.send(:set_secure_id)
      integration.save!
    end
  end

  def down
    remove_index  :integrations, :secure_id
    remove_column :integrations, :secure_id
  end
end
