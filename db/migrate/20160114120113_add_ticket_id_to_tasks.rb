class Task < ApplicationRecord
end

class AddTicketIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :ticket_id, :string
    add_index :tasks, :ticket_id, unique: true

    Task.reset_column_information

    Task.find_each(&:save)
  end
end
