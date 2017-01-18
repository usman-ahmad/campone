module IntegrationsHelper
  def webhook_url(integration)
    content_tag :code do
      "http://campone.com/webhooks/#{integration.id}"
    end
  end

  def all_available_integrations
    %w[NOTIFIABLE_INTEGRATIONS IMPORT_TASK_INTEGRATION SOURCE_CODE_INTEGRATION].map do |key|
      [key.humanize, ('Integration::'+key).constantize & Integration::AVAILABLE_INTEGRATIONS]
    end
  end
end
