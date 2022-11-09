# frozen_string_literal: true

class CreateGroupUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :group_users do |t|
      t.uuid :group_id
      t.integer :user_id
      t.text :group_key

      t.timestamps
    end

    add_index :group_users, %i[group_id user_id], unique: true
    add_foreign_key 'group_users', 'users',  name: 'fk_group_users__users',  on_delete: :cascade
    add_foreign_key 'group_users', 'groups', name: 'fk_group_users__groups', type: :uuid, on_delete: :cascade
  end
end
