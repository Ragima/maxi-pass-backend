# frozen_string_literal: true

class AddSupportPrivateVaultToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :support_personal_vaults, :boolean, default: false
  end
end
