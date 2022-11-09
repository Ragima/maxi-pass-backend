# frozen_string_literal: true

class AddColumnToVaultItem < ActiveRecord::Migration[5.2]
  def change
    add_column :vault_items, :only_for_admins, :boolean, default: nil
  end
end
