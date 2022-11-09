# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams, id: false do |t|
      t.string :name, null: false, unique: true
      t.index 'lower((name)::text)', name: 'index_teams_on_lowercase_name', unique: true, using: :btree
      t.timestamps
    end
    execute <<-SQL
      alter table teams add constraint pk primary key(name)
    SQL
  end
end
