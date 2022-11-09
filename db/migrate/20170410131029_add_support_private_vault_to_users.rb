# frozen_string_literal: true

class AddSupportPrivateVaultToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.boolean :support_personal_vaults, default: false
    end
  end
end
