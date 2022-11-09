# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
    create_table :groups, id: :uuid do |t|
      t.string :name
      t.text :admin_keys
      t.string :team_name
      t.timestamps
    end

    add_index :groups, %i[name team_name], unique: true

    # add_foreign_key "groups", "teams",  name: "fk_groups__teams",  on_delete: :cascade
    execute <<-SQL
     alter table groups add constraint fk_groups__teams foreign key (team_name) references teams(name) on delete cascade
    SQL
  end
end
