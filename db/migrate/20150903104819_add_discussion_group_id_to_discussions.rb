class AddDiscussionGroupIdToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :discussion_group_id, :integer
    add_index  :discussions, :discussion_group_id
  end
end
