# frozen_string_literal: true

class AddRecoveryNewTokenToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.string :recovery_token
    end
  end
end
