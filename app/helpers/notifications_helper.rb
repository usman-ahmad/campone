module NotificationsHelper
  def friendly_link(notification)
    task_or_discussion = notification.task_or_discussion
    project = task_or_discussion.project
    task_or_discussion_id = task_or_discussion.try(:friendly_id) || project.friendly_id

    content_tag :span do
      link_to(task_or_discussion_id, [project, task_or_discussion], class: 'text-uppercase', title: task_or_discussion.title)
    end
  end
end
