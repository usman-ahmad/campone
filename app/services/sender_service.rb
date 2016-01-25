class SenderService
  def initialize(uri,params)
    @uri     = uri
    @params  = params
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
      Rails.logger.error("SlakcService: Error when sending: #{e.message}")
    end
  end
end