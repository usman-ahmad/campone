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

class NotifiableIntegration < Integration
  def publish(message)
    begin
      uri = URI.parse(self.url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
      request.body = message_to_payload(message).to_json
      http.request(request)
    rescue => e
      Rails.logger.error("#{self.class.name}Error \nMESSAGE: #{e.message} \nURI: #{self.url} \nTRACE... \n#{e.backtrace.join("\n")}")
    end
  end
end
