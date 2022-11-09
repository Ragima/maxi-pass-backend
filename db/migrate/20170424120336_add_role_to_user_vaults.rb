# frozen_string_literal: true

class AddRoleToUserVaults < ActiveRecord::Migration[5.2]
  def change
    add_column :user_vaults, :role, :string, default: 'user'
    add_index :user_vaults, :role
  end
end
