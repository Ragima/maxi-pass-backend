# frozen_string_literal: true

class CreateUserVaults < ActiveRecord::Migration[5.2]
  def change
    create_table :user_vaults do |t|
      t.integer :user_id
      t.uuid :vault_id
      t.text :vault_key
      t.boolean :vault_writer, default: false
      t.timestamps
    end

    add_index :user_vaults, %i[user_id vault_id], unique: true
    add_foreign_key 'user_vaults', 'users',  name: 'fk_user_vaults__users',  on_delete: :cascade
    add_foreign_key 'user_vaults', 'vaults', name: 'fk_user_vaults__vaults', on_delete: :cascade
  end
end
