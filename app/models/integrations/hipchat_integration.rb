# == Schema Information
#
# Table name: integrations
#
#  id         :integer          not null, primary key
#  project_id :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  token      :string
#  secret     :string
#  type       :string
#  title      :string
#  active     :boolean
#  secure_id  :string
#

class HipchatIntegration < NotifiableIntegration
  # TODO: Test and fix this, This is old code copied from FlowdockService
  def message_to_payload(activity)
    {
        from: "Camp One",
        message: "Project: #{activity[:project_title]} -
                    #{activity[:text]} -
                    #{activity[:absolute_url]} -
                    #{activity[:description]}"
    }
  end
end
