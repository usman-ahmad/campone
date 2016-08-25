class RemoveDiscussionGroupIdFromDiscussions < ActiveRecord::Migration[5.0]
  def change
    remove_index  :discussions, :discussion_group_id
    remove_column :discussions, :discussion_group_id, :integer
  end
end
