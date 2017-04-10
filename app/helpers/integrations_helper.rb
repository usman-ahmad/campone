module IntegrationsHelper
  def webhook_url(integration)
    content_tag :code do
      accept_payload_project_integration_url(integration.project, integration)
    end
  end

  def all_available_integrations
    %w[NOTIFIABLE_INTEGRATIONS IMPORT_STORY_INTEGRATION SOURCE_CODE_INTEGRATION].map do |key|
      [key.humanize, ('Integration::'+key).constantize & Integration::AVAILABLE_INTEGRATIONS]
    end
  end
end
