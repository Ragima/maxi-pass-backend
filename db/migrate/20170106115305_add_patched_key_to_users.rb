# frozen_string_literal: true

class AddPatchedKeyToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.boolean :patched, default: false
    end
  end
end
