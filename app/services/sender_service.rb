class SenderService
  def initialize(uri, params)
    @uri = uri
    @params = params
  end

  def deliver
    begin
      uri = URI.parse(@uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
      request.body = @params.to_json
      response = http.request(request)
      response.body
    rescue => e
      Rails.logger.error("Sender Service: Error when sending on #{@uri}: #{e.message}")
    end
  end

  def build(integration, activity_data)
    case integration.name
      when 'slack'
        SlackService.new(integration.url, activity_data)
      when 'hipchat'
        HipchatService.new(integration.url, activity_data)
      when 'flowdock'
        FlowdockService.new(integration.url, activity_data)
      when 'twitter'
        TwitterService.new(integration.url, activity_data)
      else
        raise 'NOT Sender Service'
    end
  end
end
