# frozen_string_literal: true

class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.2]
  def change
    change_table(:users) do |t|
      t.string :uid, null: false, default: ''
      t.string :provider, null: false, default: 'email'
      t.jsonb :tokens
    end
  end
end
