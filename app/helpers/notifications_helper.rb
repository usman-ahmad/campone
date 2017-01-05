module NotificationsHelper
  def main_link(notification)
    link_text = notification.resource_fid || notification.project_fid # append ID with project_fid? for discussions
    content_tag :span do
      link_to(link_text, notification.resource_link, class: 'text-uppercase')
    end
  end


  def text_with_link(notification)
    if notification.comment?
      notification.text
    else
      link_to notification.text, notification.resource_link
    end
  end

  # TODO: Delete all views for public_activity
  def render_notification(notification)
    # TODO: Add resource link
    [notification.resource_action, notification.text].join(' ')
  end
end
