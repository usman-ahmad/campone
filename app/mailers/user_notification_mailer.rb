class UserNotificationMailer < ApplicationMailer

  def new_story_notification(user, notification_content)
    @notification = notification_content
    subject = "A new story is created."
    mail(to: user.email, subject: subject)
  end

  def ownership_changed(user, notification_content)
    @notification = notification_content
    subject = "Story ownership is changed"
    mail(to: user.email, subject: subject)
  end

  def story_state_changed(user, notification_content)
    @notification = notification_content
    subject = "Story state is changed"
    mail(to: user.email, subject: subject)
  end

  def comment_created(user, notification_content)
    @notification = notification_content
    subject = "Comment created on story"
    mail(to: user.email, subject: subject)
  end
end