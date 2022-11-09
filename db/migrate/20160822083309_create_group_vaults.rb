# frozen_string_literal: true

class CreateGroupVaults < ActiveRecord::Migration[5.2]
  def change
    create_table :group_vaults do |t|
      t.uuid :group_id
      t.uuid :vault_id
      t.text :vault_key

      t.timestamps
    end
    add_index :group_vaults, %i[group_id vault_id], unique: true
    add_foreign_key 'group_vaults', 'groups', name: 'fk_group_vaults__groups', on_delete: :cascade
    add_foreign_key 'group_vaults', 'vaults', name: 'fk_group_vaults__vaults', on_delete: :cascade
  end
end
