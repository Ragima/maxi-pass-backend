class ChangeAdminKeysToJsonb < ActiveRecord::Migration[5.2]
  def change
    change_column :groups, :admin_keys, 'jsonb using admin_keys::jsonb', default: '{}'
    change_column :vaults, :admin_keys, 'jsonb using admin_keys::jsonb', default: '{}'
  end
end
