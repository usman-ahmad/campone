# UA[2017/01/03] - MOVED ATTACHABLE MODULE CODE TO STORY AND DISCUSSION MODELS - TO ACHIEVE HIGH COHESION AND LOW COUPLING
# module Attachable
#   def attachments_array=(array)
#     return unless array.present?
#
#     array.each do |file|
#       attachments.build(:document => file, project: self.project, uploader_id: self.user_id)
#     end
#   end
# end
