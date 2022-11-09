# frozen_string_literal: true

class AddAuthenticationColumnToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.string :authentication_type, default: 'none'
    end
  end
end
