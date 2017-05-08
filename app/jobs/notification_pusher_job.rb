class NotificationPusherJob < ApplicationJob
  queue_as :default

  def perform(receiver, content)
    # Do something later
    NotificationChannel.broadcast_to(receiver, content: content)
  end

end
