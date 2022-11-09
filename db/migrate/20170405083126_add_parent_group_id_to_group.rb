# frozen_string_literal: true

class AddParentGroupIdToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :parent_group_id, :uuid
    add_index :groups, :parent_group_id
  end
end
