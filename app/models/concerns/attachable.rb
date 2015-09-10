module Attachable
  def attachments_array=(array)
    array.each do |file|
      attachments.build(:attachment => file, project: self.project)
    end
  end
end