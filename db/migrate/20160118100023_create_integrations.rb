class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.references :project, index: true, foreign_key: true
      t.string :url
      t.timestamps null: false
    end
  end
end
