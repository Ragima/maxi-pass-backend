# frozen_string_literal: true

class AddTeamToActivities < ActiveRecord::Migration[5.2]
  def up
    change_table :activities do |t|
      t.string :team_name, null: true
    end
    add_index :activities, :team_name
    execute <<-SQL
      alter table activities add constraint fk_activities_team foreign key (team_name) references teams(name) on delete cascade
    SQL
  end

  def down
    remove_index :activities, column: :team_name
    execute <<-SQL
      alter table activities drop constraint fk_activities_team
    SQL
    remove_column :activities, :team_name
  end
end
