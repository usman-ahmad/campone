module CommentsHelper
  def commentable_url(comment)
    Rails.application.routes.url_helpers.send("project_#{comment.commentable_type.underscore}_path" ,comment.commentable.project, comment.commentable)
  end

  def comment_url(comment)
    Rails.application.routes.url_helpers.send("project_#{comment.commentable_type.underscore}_comment_path" ,comment.commentable.project, comment.commentable, comment)
  end
end
