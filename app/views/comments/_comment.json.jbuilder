json.(comment, :id, :content)
json.user comment.user.name
json.content comment.content
json.time distance_of_time_in_words(Time.current, comment.created_at)
json.url comment_url(comment)
json.attachments comment.attachments, partial: 'attachments/attachment', as: :attachment, locals:{ project: comment.project}
json.resource_id resource_div_id(comment)