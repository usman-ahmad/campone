class AddInheritanceToIntegrations < ActiveRecord::Migration[5.0]
  def change
    add_column :integrations, :type, :string
    add_column :integrations, :title, :string
    add_column :integrations, :active, :boolean
    Integration.reset_column_information

    # For now we have created classes only for these integrations,
    # it would fail if we change type for all integrations if we have other integrations i-e bitbucket
    integrations = Integration.where(name: Integration::AVAILABLE_INTEGRATIONS)
    integrations.each do |integration|
      integration.update_column(:type, integration.name.capitalize + "Integration")
    end

    # TODO: DELETE name column, Not deleting it yet because we may have other then above integrations
    # remove_column :integrations, :name
  end
end
