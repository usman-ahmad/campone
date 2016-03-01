# TODO: There should be one import against one project, Do't make redundant tasks
class ImportService
  attr_reader :client

  def initialize(integration)
    @integration = integration
    @project = integration.project
    set_client
  end
  # This is abstract layer that automatically return Child classes according to integration. like Factory pattern
  # I am not creating new class here for simplicity
  def self.build(integration)
    case integration.name
      when 'trello'
        TrelloImport.new(integration)
      when 'jira'
        JiraImport.new(integration)
      when 'asana'
        AsanaImport.new(integration)
      else
        Raise 'Unable to import from this integration'
    end
  end
end