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

class FlowdockIntegration < NotifiableIntegration
  def message_to_payload(activity)
    {
        event: 'activity',
        author: {
            name: "#{activity[:performer_name]}",
            # avatar: "https://avatars.githubusercontent.com/u/3017123?v=3"
        },
        title: activity[:text],
        external_thread_id: "#{activity[:resource_id]}", #it should be trackable id
        thread: {
            title: "Project: #{activity[:project_title]} > #{activity[:text]}",
            # body: "If there is any discription it will go here",
            external_url: "#{activity[:absolute_url]}",
            status: {
                color: 'green',
                # TODO: Set Correct value
                value: 'OK'
            }
        }
    }
  end
end
