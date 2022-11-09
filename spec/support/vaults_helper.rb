# frozen_string_literal: true

module VaultsHelper
  def create_shared_vault(user, params_hash = {})
    vault = create :vault, params_hash.merge(team: user.team)
    vault.is_shared = true
    encoder = Encoder.new(user)
    vault_key = encoder.generate_sym_key(user)
    encrypted_sym_key = encoder.encrypt_sym_key(user, vault_key)
    encoder.update_vault_key_for_admin_users(user, vault, vault_key)
    UserVault.create(user: user, vault: vault, vault_key: encrypted_sym_key) unless user.admin?
    vault.save
    vault
  end

  def create_private_vault(user, params_hash = {})
    vault = create :vault, params_hash.merge(team: user.team)
    vault.user_id = user.id
    encoder = Encoder.new(user)
    vault_key = encoder.generate_sym_key(user)
    encrypted_sym_key = encoder.encrypt_sym_key(user, vault_key)
    UserVault.create(user: user, vault: vault, vault_key: encrypted_sym_key)
    vault.save
    vault
  end
end