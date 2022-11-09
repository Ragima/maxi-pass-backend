# frozen_string_literal: true

class AddRecoveryTokenToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.string :name
      t.boolean :reset_pass, default: false
      t.boolean :change_pass, default: false
    end
  end
end
