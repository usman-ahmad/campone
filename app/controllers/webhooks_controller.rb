class WebhooksController < ActionController::Base
  # include GithubWebhook::Processor

  # add github events according to your requirements
  # each method name would be a event name.
  # like this
  # def commit_comment(payload)
  # end

  # def push(payload)
  #   # TODO: handle push webhook
  # end
  #
  # def webhook_secret(payload)
  #   ENV['GITHUB_WEBHOOK_SECRET']
  # end

  before_action :getIntegration

  def create
    @integration.create_payload params
    head(:ok)
   end

=begin
  GS: Don't use integration_id, if some third person adds a hook with some random wrong id,
  spam will begin generating for original project
=end
  def getIntegration
    @integration = Integration.find(params["integration_id"].to_i)
  end
end