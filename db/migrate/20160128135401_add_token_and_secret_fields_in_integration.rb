class AddTokenAndSecretFieldsInIntegration < ActiveRecord::Migration
  def change
    add_column :integrations, :token, :string
    add_column :integrations, :secret, :string
  end
end
