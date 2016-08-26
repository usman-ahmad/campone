class ChangeRoleColumnToStringFromContributions < ActiveRecord::Migration[5.0]
  def self.up
    change_column :contributions, :role, :string
  end

  def self.down
    change_column :contributions, :role, :integer
  end
end
