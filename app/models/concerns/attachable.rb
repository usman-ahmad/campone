module Attachable
  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:document => file, project: self.project, user_id: self.user_id)
    end
  end
end
