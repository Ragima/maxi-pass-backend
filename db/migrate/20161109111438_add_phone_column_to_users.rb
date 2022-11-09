# frozen_string_literal: true

class AddPhoneColumnToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.string :phone_number
    end
  end
end
