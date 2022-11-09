# frozen_string_literal: true

class AddTeamNameToServices < ActiveRecord::Migration[5.2]
  def change
    add_column :services, :team_name, :string
    add_index :services, :team_name
  end
end
