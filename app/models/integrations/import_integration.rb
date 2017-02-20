# == Schema Information
#
# Table name: integrations
#
#  id         :integer          not null, primary key
#  project_id :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  token      :string
#  secret     :string
#  type       :string
#  title      :string
#  active     :boolean
#

# TODO: There should be one import against one project, Do't make redundant stories
class ImportIntegration < Integration
  attr_reader :client

  # def initialize(integration)
  #   @integration = integration
  #   @project = integration.project
  #   set_client
  # end

  # This is abstract layer that automatically return Child classes according to integration. like Factory pattern
  # I am not creating new class here for simplicity
  # def self.build(integration)
  # # TODO: Refactor this method, in fact whole class, no need for this class
  #   integration.set_client
  #
  #   case integration.name
  #     when 'asana'
  #       integration
  #     when 'jira'
  #         integration
  #     when 'trello'
  #         integration
  #     else
  #       raise 'Unable to import from this integration'
  #   end
  # end
end
