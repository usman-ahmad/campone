class WebhooksController < ActionController::Base
  before_action :getIntegration

  def create
    # HEAD request is used trello for handshaking in confirmation of webhook
    if request.head?
      head(:ok)
    elsif request.headers['X-Hook-Secret'].present? # Asana hanshake
      options = {}
      # asana wants OK (200) response along with secret in head
      options['X-Hook-Secret'] = request.headers['X-Hook-Secret'] if @integration.name == 'asana'
      head(:ok, options)
    else # save this payload
      @integration.payloads.create(info: params, event: event_name)
      head(:ok)
    end
  end

=begin
  GS: Don't use integration_id, if some third person adds a hook with some random wrong id,
  spam will begin generating for original project
=end
  def getIntegration
    @integration = Integration.find(params["integration_id"].to_i)
  end

  def event_name
    case @integration.name
      when 'github'
        request.headers['X-GitHub-Event']
      when 'bitbucket'
        request.headers['HTTP_X_EVENT_KEY'].split(':')[1]
      when 'trello'
        params['webhook']['action']['type']
      when 'jira'
        params['webhookEvent']
      else
        nil # Will not save this webhook
    end
  end
end
