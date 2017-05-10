# TODO: DELETE. Not being used anymore.
# class GithubParser < VCSParser
#
#   def initialize(payload)
#     super(payload)
#   end
#
#   #Formate defined in Parent Class
#   def push
#     commits = @payload["commits"]
#     total_commits = commits.count # No need to store this in new variable, we can use commits.count
#     pusher = @payload["pusher"]["name"]
#     message_header = "#{total_commits} new commits pushed by #{pusher}"
#     head_name = "HEAD_NAME" # required to fil
#     head_url = "HEAD_URL"   # required to fil
#
#     message = {"head": "#{message_header}","head_name":"#{head_name}", "head_url": "#{head_url}", "vcs_name":"github","commits": []}
#
#     commits.each do |commit|
#       id = commit["id"]
#       url = commit["url"]
#       commit_message = "#{commit["message"]} - #{commit["committer"]["name"]}"
#       commit_info = {"id": "#{id}", "url": "#{url}", "message": "#{commit_message}"}
#       message[:commits] << commit_info
#     end
#
#     return message
#   end
#
#   #Formate defined in Parent Class
#   def get_commit_messages
#     commits = @payload["commits"]
#     messages = []
#     commits.each do |commit|
#     commit_info = {
#           message: "#{commit["message"]}",
#           author: { email: "#{commit["committer"]["email"]}", name: "#{commit["committer"]["name"]}"}}
#       messages << commit_info
#     end
#     return messages
#   end
#
# end
