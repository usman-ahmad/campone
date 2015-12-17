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
      notice = Notification.create!(activity_id: self.id, user_id: user)
      send_notifications_to_user( notice,user)
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

  def send_notifications_to_user(notice,user_id)
     user_email = User.find(user_id).email
     notice_id = notice.id
      notice_created_at = notice.created_at
      message =  create_message(notice)
     PrivatePub.publish_to('/messages/private/user'+ user_id.to_s, message: "#{message}")
  end

  def create_message(notice)
    message = notice.id.to_s + '|' + notice.created_at.to_s + '|'+notice.activity.owner.name.to_s
   if notice.activity.trackable_type.to_s!= 'Comment'
    if notice.activity.key.include? "create"
      message += ' created '
     elsif notice.activity.key.include? "update"
      message += ' updated '
     end
    message += notice.activity.trackable_type.to_s
    message += ' ' + notice.activity.trackable.title.to_s if notice.activity.trackable.title.present?
   else
      message += ' Commented on ' + notice.activity.trackable.commentable.title

   end
  end
end