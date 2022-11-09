# frozen_string_literal: true

class CreateVaults < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'uuid-ossp'

    create_table :vaults, id: :uuid do |t|
      t.string :title
      t.text :description
      t.text :admin_keys
      t.timestamps
      t.boolean :is_shared, default: false
      t.string :team_name, optional: true
      t.integer :user_id, optional: true
    end
    # add_foreign_key "vaults", "teams",  name: "fk_vaults__teams",  on_delete: :cascade
    execute <<-SQL
     alter table vaults add constraint fk_vaults__teams foreign key (team_name) references teams(name) on delete cascade
    SQL
    execute <<-SQL
    alter table vaults add constraint fk_vaults__users foreign key (user_id) references users(id) on delete cascade
    SQL
  end
end
