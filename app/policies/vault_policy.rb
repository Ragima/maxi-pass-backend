class VaultPolicy < ApplicationPolicy
  include Users::Concerns::Role

  def initialize(user, vault)
    @user = user
    @vault = vault
  end

  def generate_report?
    @user.vault_admin_or_lead?(@vault) && @vault.is_shared
  end
end
