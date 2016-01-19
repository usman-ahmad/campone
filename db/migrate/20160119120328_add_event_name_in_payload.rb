class AddEventNameInPayload < ActiveRecord::Migration
  def change
    add_column :payloads, :event, :string
  end
end
