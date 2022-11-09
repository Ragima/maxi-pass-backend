class ChangeAdminKeysEmptyValue < ActiveRecord::Migration[5.2]
  def change
    Vault.where(admin_keys: nil).update_all(admin_keys: {})
    Group.where(admin_keys: nil).update_all(admin_keys: {})
  end
end
