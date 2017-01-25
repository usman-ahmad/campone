class AddCloseByToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :stories, :closed_at, :datetime
    add_column :stories, :closed_by_id, :integer
    add_column :stories, :closed_by_user_name, :string
  end
end
