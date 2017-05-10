# TODO: Delete. Code Moved to SlackIntegration
# class SlackService < SenderService
#
#   def initialize(uri, params)
#     super(uri, params)
#   end
#
#   def self.message(activity)
#     {
#         "username": "Camp One",
#         "attachments": [
#             {
#                 "pretext": "Project: #{activity[:project_title]}",
#                 "title": activity[:text],
#                 "title_link": activity[:absolute_url],
#                 "text": activity[:description],
#                 "color": "#7CD197"
#             }
#         ]
#     }
#   end
#
# end
