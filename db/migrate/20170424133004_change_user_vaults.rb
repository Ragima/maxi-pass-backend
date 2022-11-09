# frozen_string_literal: true

class ChangeUserVaults < ActiveRecord::Migration[5.2]
  def change
    UserVault.where(vault_writer: true).update(role: 'lead')
  end
end
