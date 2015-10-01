PublicActivity::Activity.class_eval do
  has_many :notifications
  has_many :users, through: :notifications

  after_create :create_notification

  def create_notification
    users_to_notify = case self.trackable_type
                        when "Task"
                          get_notifiable_users_for_task(trackable)
                        when "Discussion"
                          get_notifiable_users_for_discussion(trackable)
                        when "Comment"
                          get_notifiable_users_for_comment
                      end

    users_to_notify.each do |user|
      Notification.create!(activity_id: self.id, user_id: user)
    end
  end

  def get_notifiable_users_for_task(task)
    task.project.members.map(&:id)
  end

  def get_notifiable_users_for_discussion(discussion)
    discussion.users.map(&:id)
  end

  def get_notifiable_users_for_comment
    case trackable.commentable_type
      when "Task"
        get_notifiable_users_for_task(trackable.commentable)
      when "Discussion"
        get_notifiable_users_for_discussion(trackable.commentable)
    end
  end
end