class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      # t.integer :commentable_id
      # t.string :commentable_type
      t.belongs_to :commentable, polymorphic: true # We can use this line instead of above two

      t.timestamps null: false
    end
    add_index :comments, [:commentable_id, :commentable_type]
  end
end
