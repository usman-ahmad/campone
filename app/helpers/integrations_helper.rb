module IntegrationsHelper
  def webhook_url(integration)
    content_tag :code do
      "http://campone.com/webhooks/#{integration.id}"
    end
  end
end
