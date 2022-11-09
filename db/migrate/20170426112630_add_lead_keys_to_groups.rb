# frozen_string_literal: true

class AddLeadKeysToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :lead_keys, :text
  end
end
