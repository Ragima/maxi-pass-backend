# frozen_string_literal: true

class AddExtensionAccessToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :extension_access, :boolean, default: false
  end
end
