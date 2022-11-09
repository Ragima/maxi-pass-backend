# frozen_string_literal: true

class AddTeamNameToActivities < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
   Update activities
	      set team_name=(SELECT substring(a.parameters from '%:team_id: |"[0-9a-zA-z]+|"%' for '|')
				from activities as a where a.id=activities.id);
    SQL
  end
end
