class AddCurrentTicketIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :current_ticket_id, :integer, default: 1
  end
end
