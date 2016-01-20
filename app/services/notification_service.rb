class Notification_sender

  def send_notification(notice, users_to_notify)
    users_to_notify.each do |user|
      begin
        PrivatePub.publish_to('/messages/private/user'+ user.id.to_s, message: "#{notice}")
      rescue => ex
        logger.error ex.message
      end
    end
  end

end