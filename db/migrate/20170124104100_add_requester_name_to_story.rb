class AddRequesterNameToStory < ActiveRecord::Migration[5.0]
  def up
    add_column :stories, :requester_name, :string
    Story.reset_column_information
    Story.find_each do |story|
      if story.requester.present?
        story.requester_name = story.requester.name
        story.save
      end
    end
  end

  def down
    remove_column :stories, :requester_name, :string
  end
end
