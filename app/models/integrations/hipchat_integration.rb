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
#

class HipchatIntegration < NotifiableIntegration
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
