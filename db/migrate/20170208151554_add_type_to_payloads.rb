class AddTypeToPayloads < ActiveRecord::Migration[5.0]
  def change
    add_column :payloads, :type, :string
  end
end
