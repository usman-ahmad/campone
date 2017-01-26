class AddUsernameToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :username, :string
    add_index :users, :username, unique: true

    User.find_each do |user|
      if user.name.present?
        user_name = user.name.split.join('_').downcase
        user.username = User.exists?(username: user_name) ? user_name + '_' + user.id.to_s : user_name
        user.save
      end
    end
  end

  def down
    remove_index :users, :username
    remove_column :users, :username, :string
  end
end
