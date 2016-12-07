class AddTokenAndStatusAndInviterIdToContributions < ActiveRecord::Migration[5.0]
  def change
    add_column :contributions, :token, :string
    add_column :contributions, :status, :string, :default => 'pending'

    # rails 5 way - https://github.com/rails/rails/issues/25169 # issues with rollback on postgresql
    # add_reference :contributions, :inviter, foreign_key: {to_table: :users}
    # rails 4 way
    add_reference :contributions, :inviter, references: :users, index: true
    add_foreign_key :contributions, :users, column: :inviter_id
  end
end
