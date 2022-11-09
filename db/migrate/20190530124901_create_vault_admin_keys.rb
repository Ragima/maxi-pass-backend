# frozen_string_literal: true

class CreateVaultAdminKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :vault_admin_keys do |t|
      t.references :vault, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :user, type: :integer, foreign_key: { on_delete: :cascade }
      t.string :key
    end
  end
end
