class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.text :info
      t.references :integration, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
