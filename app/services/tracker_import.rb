# require 'tracker_api'
#
# # TODO: Move this to integrations
# class TrackerImport < ImportService
#   attr_reader :client
#
#   def set_client
#     @client = TrackerApi::Client.new(token: @integration.token)
#   end
#
#   def import!(external_project_id)
#     project  = @client.project(external_project_id)
#
#     # Use Background Job here
#     project.stories.each do |story|
#       import_story(story)
#     end
#   end
#
#   def import_story(story)
#     # TODO: Manage Attachments and grouping
#     attributes = {
#         title: story.name,
#         description: story.description,
#         due_at: story.deadline,
#         updated_at: story.updated_at,
#         state: map_state(story.current_state),
#     }
#
#     @project.stories.create(attributes)
#   end
#
#
#   def project_list
#     projects = []
#
#     client.projects.each do |p|
#       projects << { title: p.title, id: p.id }
#     end
#
#     projects
#   end
#
#   private
#
#   def map_state(state)
#     # planned is mapped to NO_PROGRESS or unstarted
#     case state
#       when 'unscheduled'
#         Story::STATE_MAP[:NOT_SCHEDULED]
#       when 'unstarted'
#         Story::STATE_MAP[:NO_PROGRESS]
#       when 'started'
#         Story::STATE_MAP[:IN_PROGRESS]
#       when 'finished'
#         Story::STATE_MAP[:COMPLETED]
#       when 'delivered'
#         Story::STATE_MAP[:DEPLOYED]
#       when 'rejected'
#         Story::STATE_MAP[:REJECTED]
#       when 'accepted'
#         Story::STATE_MAP[:ACCEPTED]
#       else
#         Story::STATES[:NO_PROGRESS]
#     end
#   end
#
# end
