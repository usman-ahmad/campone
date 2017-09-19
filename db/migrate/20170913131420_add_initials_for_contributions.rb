class AddInitialsForContributions < ActiveRecord::Migration[5.0]
  def up
    add_column :contributions, :initials, :string

    Contribution.reset_column_information
    Contribution.includes(:user).find_each do |c|
      c.save # resaving will set initials
    end
  end

  def down
    remove_column :contributions, :initials, :string
  end
end
