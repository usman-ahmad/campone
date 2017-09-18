json.(@story, :id, :title, :description, :priority, :due_at, :state, :ticket_id, :project_id, :story_type)
json.requester_name  @story.requester.try(:name)
json.owner  story_assigned_to(@story)
json.url project_story_path(@project, @story)
json.comments_path project_story_comments_path(@project, @story)

json.attachments @story.attachments, partial: 'attachments/attachment', as: :attachment, locals: {project: @project}
json.comments @story.comments.order_asc, partial: 'comments/comment', as: :comment, locals: {story: @story, project: @project}
