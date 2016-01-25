class WebhooksController < ActionController::Base
  before_action :getIntegration

  def create
    @integration.payloads.create(info: params, event: event_name)
    head(:ok)
  end

=begin
  GS: Don't use integration_id, if some third person adds a hook with some random wrong id,
  spam will begin generating for original project
=end
  def getIntegration
    @integration = Integration.find(params["integration_id"].to_i)
  end

  def event_name
    name = @integration.name
    request.headers['X-GitHub-Event'] if name == "github"
    request.headers['HTTP_X_EVENT_KEY'].split(':')[1] if name == "bitbucket"
    #In the same way we will extract event name from bitbuckit or other vcs payloads or requests
  end
end