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

class SlackIntegration < NotifiableIntegration
  def message_to_payload(activity)
    {
        username: 'Camp One',
        attachments: [
            {
                pretext: "Project: #{activity[:project_title]}",
                title: activity[:text],
                title_link: activity[:absolute_url],
                text: activity[:description],
                color: "#7CD197"
            }
        ]
    }
  end
end
