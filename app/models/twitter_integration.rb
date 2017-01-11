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

class TwitterIntegration < NotifiableIntegration

  # Overriding `publish` method as Twitter is different from other Notifiable Integrations
  def publish(message)
    begin
      client = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_KEY']
        config.consumer_secret = ENV['TWITTER_SECRET']
        config.access_token = integration.token
        config.access_token_secret = integration.secret
      end

      client.update(message_to_payload(message))

    rescue => e
      Rails.logger.error("#{self.class.name}Error \nMESSAGE: #{e.message} \nURI: #{self.url} \nTRACE... \n#{e.backtrace.join("\n")}")
    end
  end

  def message_to_payload(activity)
    # TODO: Apply limit
    "From : CampOne
     Project : #{activity[:project_title]}
    #{activity[:text]}
    #{activity[:description]}"
  end
end
