class AddFieldsToUsers < ActiveRecord::Migration
  def up
    add_column     :users, :name, :string
    add_attachment :users, :avatar
    end
  def down
    remove_column     :users, :name, :string
    remove_attachment :users, :avatar
  end
end
