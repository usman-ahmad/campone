module IntegrationsHelper
  def webhook_url(integration)
    content_tag :code do
      "#{ENV['HOST']}/webhooks/#{integration.secure_id}"
    end
  end

  def all_available_integrations
    %w[NOTIFIABLE_INTEGRATIONS IMPORT_STORY_INTEGRATION SOURCE_CODE_INTEGRATION].map do |key|
      [key.humanize, ('Integration::'+key).constantize & Integration::AVAILABLE_INTEGRATIONS]
    end
  end
end
