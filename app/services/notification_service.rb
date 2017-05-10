# TODO: Delete, only referenced from SourceCodePayload
# GS[2017/05/09] We are using action_cable now, see NotificationPusherJob
# class NotificationService
#
#   def send_notification(notice, users_to_notify)
#     (notice = ('| |' + notice)) if notice.split('|').count == 1
#     users_to_notify.each do |user|
#       begin
#         PrivatePub.publish_to('/messages/private/user'+ user.id.to_s, message: "#{notice}")
#       rescue => ex
#         logger.error ex.message
#       end
#     end
#   end
#
# end
