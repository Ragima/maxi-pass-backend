class FillAdminKeys < ActiveRecord::Migration[5.2]
  def change
    Group.reset_column_information
    Vault.reset_column_information
    Group.all.find_each do |group|
      admin_keys = group.admin_keys.keys
      admin_keys.each do |admin_key|
        GroupAdminKey.create(group: group, user_id: admin_key.to_i, key: group.admin_keys[admin_key])
      end
    end
    Vault.all.find_each do |vault|
      admin_keys = vault.admin_keys.keys
      admin_keys.each do |admin_key|
        VaultAdminKey.create(vault: vault, user_id: admin_key.to_i, key: vault.admin_keys[admin_key])
      end
    end
  end
end
