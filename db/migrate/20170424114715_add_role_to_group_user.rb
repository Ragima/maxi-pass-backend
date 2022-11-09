# frozen_string_literal: true

class AddRoleToGroupUser < ActiveRecord::Migration[5.2]
  def change
    add_column :group_users, :role, :string, default: 'user'
    add_index :group_users, :role
  end
end
