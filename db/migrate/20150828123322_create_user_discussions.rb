class CreateUserDiscussions < ActiveRecord::Migration
  def change
    create_table :user_discussions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :discussion, index: true, foreign_key: true
      t.boolean :notify

      t.timestamps null: false
    end
  end
end
