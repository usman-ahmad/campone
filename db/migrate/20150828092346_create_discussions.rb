class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :title
      t.text :content
      t.boolean :private
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
