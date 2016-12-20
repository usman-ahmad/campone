PublicActivity::Activity.class_eval do
  has_many :notifications
  has_many :users, through: :notifications

  after_create :create_notification, :send_slack_notification, :send_hipchat_notification, :send_flowdock_notification, :send_twitter_notification

  def create_notification
    users_to_notify = case self.trackable_type
                        when 'Task'
                          get_notifiable_users_for_task(trackable)
                        when 'Discussion'
                          get_notifiable_users_for_discussion(trackable)
                        when "Comment"
                          get_notifiable_users_for_comment
                      end

    users_to_notify.each do |user|
      notice = Notification.create!(activity_id: self.id, user_id: user)
      send_notifications_to_user( notice,user)
    end
  end

  # We require to run this function with delayjobs
  def send_slack_notification
    project.integrations.slack_urls.each do |url|
      SlackService.new(url, SlackService.message(self)).deliver
    end
  end

  def send_hipchat_notification
    project.integrations.hipchat_urls.each do |url|
      HipchatService.new(url, HipchatService.message(self)).deliver
    end
  end

  def send_flowdock_notification
    project.integrations.flowdock_urls.each do |url|
      FlowdockService.new(url, FlowdockService.message(self)).deliver
    end
  end

  def send_twitter_notification
    TwitterService.new.get_twitter_clients(project).each do |twitter_client|
      twitter_client.update(TwitterService.message(self))
    end
  end

  def get_notifiable_users_for_task(task)
    # owner_id represents current_user, Do not send notifications to reporter
    task.project.members.map(&:id) - [owner_id]
  end

  def get_notifiable_users_for_attachment(attachment)
    # owner_id represents current_user, Do not send notifications to creator
    attachment.project.members.map(&:id) - [owner_id]
  end

  def get_notifiable_users_for_discussion(discussion)
    if discussion.private?
      discussion.users.map(&:id) - [owner_id]
    else
      discussion.project.members.map(&:id) - [owner_id]
    end
  end

  def get_notifiable_users_for_comment
    case trackable.commentable_type
      when 'Task'
        get_notifiable_users_for_task(trackable.commentable)
      when 'Discussion'
        get_notifiable_users_for_discussion(trackable.commentable)
      when 'Attachment'
        get_notifiable_users_for_attachment(trackable.commentable)
    end
  end

  def project
    case self.trackable_type
      when 'Task', 'Discussion'
        trackable.project
      when 'Comment'
        trackable.commentable.project
      else
        raise "Project NOT found for: #{self.trackable_type}"
    end
  end

  def activty_type
    key.split('.')[1] + 'd ' + key.split('.')[0]
  end

  def get_trackable
    case self.trackable_type
      when 'Task', 'Discussion'
        trackable
      when "Comment"
        trackable.commentable
    end
  end


  def discription
    text = case self.trackable_type
             when 'Task', 'Discussion'
               "#{owner.name}: " + activty_type
             when "Comment"
               "#{owner.name}: " + activty_type + ': '+ trackable.content
           end
    ActionController::Base.helpers.strip_tags text
  end

  def get_trackable_url
    case self.trackable_type
      when 'Task', 'Discussion'
        "#{ENV['HOST']}/projects/#{project.id.to_s}/#{trackable_type.downcase}s/#{trackable.id.to_s}"
      when "Comment"
        "#{ENV['HOST']}/projects/#{project.id.to_s}/#{trackable.commentable_type.downcase}s/#{trackable.commentable.id.to_s}"
    end
  end

  def send_notifications_to_user(notice, user_id)
    user_email = User.find(user_id).email
    notice_id = notice.id
    notice_created_at = notice.created_at
    message = create_message(notice)
    begin
      PrivatePub.publish_to('/messages/private/user'+ user_id.to_s, message: "#{message}")
    rescue => ex
      logger.error ex.message
    end

  end

  def create_message(notice)
    message = notice.id.to_s + '|' + notice.created_at.to_s + '|'+notice.activity.owner.name.to_s
    if notice.comment?
     message += ' Commented on ' + notice.task_or_discussion.title
    else
      if notice.activity.key.include? "create"
        message += ' created '
      elsif notice.activity.key.include? "update"
        message += ' updated '
      end
      message += notice.activity.trackable_type.to_s
      message += ' ' + notice.trackable.title.to_s if notice.trackable.title.present?
    end

    message
  end
end
