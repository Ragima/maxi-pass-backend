# frozen_string_literal: true

class CreateVaultItems < ActiveRecord::Migration[5.2]
  def change
    create_table :vault_items do |t|
      t.string :type
      t.string :title
      t.text :tags
      t.uuid :vault_id
      t.text :content
      t.timestamps
    end
    execute <<-SQL.squish
    alter table vault_items add constraint fk_vault_items__vaults foreign key (vault_id) references vaults(id) on delete cascade
    SQL
  end
end
