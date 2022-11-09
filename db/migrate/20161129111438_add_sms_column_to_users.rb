# frozen_string_literal: true

class AddSmsColumnToUsers < ActiveRecord::Migration[5.2]
  def up
    change_table :users do |t|
      t.string :sms_code
    end
  end
end
