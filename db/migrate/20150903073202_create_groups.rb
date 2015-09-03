class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :type

      t.timestamps null: false
    end

    add_index :groups, :type
  end
end
