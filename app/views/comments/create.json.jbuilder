json.(@comment, :id, :content)
json.user @comment.user.name
json.time distance_of_time_in_words(Time.current, @comment.created_at)
json.url project_story_comment_path(@project, @commentable, @comment)