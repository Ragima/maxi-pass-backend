# frozen_string_literal: true

class AddDoneColumnToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :done, :boolean, default: false
  end
end
