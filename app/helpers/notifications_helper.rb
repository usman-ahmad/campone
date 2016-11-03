module NotificationsHelper
  # Produce links like 'ProjectID:TaskID'
  def notification_links(notification)
    task_or_discussion = notification.task_or_discussion
    project = task_or_discussion.project

    content_tag :span do
      task_or_discussion_id = task_or_discussion.try(:friendly_id).split('-')[-1] || task_or_discussion.id
      concat link_to(project.friendly_id, project_path(project), title: project.name)
      concat " : "
      concat link_to(task_or_discussion_id, [project, task_or_discussion], title: task_or_discussion.title)
    end
  end
end
