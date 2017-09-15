json.(@story, :id, :title, :description, :priority, :due_at, :state, :ticket_id, :project_id, :story_type)
json.requester_name  @story.requester.try(:name)
json.owner  story_assigned_to(@story)

# TODO Remove duplication
json.attachments @story.attachments do |attachment|
  json.title attachment.document_file_name
  json.url attachment.document.url
  json.type attachment.document_content_type
  json.thumb attachment.document.url(:thumb)
  json.attachment_path project_attachment_path(@story.project, attachment)
  json.download_attachment_path download_project_attachment_path(@story.project, attachment)
end

json.comments_path project_story_comments_path(@story.project, @story)
json.comments @story.comments do |comment|
  json.user comment.user.name
  json.content comment.content
  json.time distance_of_time_in_words(Time.current, comment.created_at)
  json.url project_story_comment_path(@story.project, @story, comment)

  json.attachments comment.attachments do |attachment|
    json.title attachment.document_file_name
    json.url attachment.document.url
    json.thumb attachment.document.url(:thumb)
    json.type attachment.document_content_type
    json.attachment_path project_attachment_path(@story.project, attachment)
    json.download_attachment_path download_project_attachment_path(@story.project, attachment)
  end

end