# frozen_string_literal: true

module Vault::Operation
  class Show < Trailblazer::Operation
    step Model(Vault, :find_by)
    step Policy::Pundit(Vault::Policy::VaultPolicy, :show?)
    success :serialized_model!
    step :assign_group_vaults!
    step :assign_groups!
    step :assign_user_vaults!
    step :assign_users!

    def serialized_model!(options, model:, current_user:, **)
      serialized_vault = Vault::Representer::Show.new(model).to_hash
      serialized_vault['data']['updatable'] = Vault::Policy::VaultPolicy.new(current_user, model).change_vault_items?
      serialized_vault['data']['has_access'] = Vault::Policy::VaultPolicy.new(current_user, model).change_vault_items?
      options[:serialized_model] = serialized_vault
    end

    def assign_group_vaults!(_options, model:, serialized_model:, **)
      group_vaults = GroupVault.where(vault: model)
      serialized_model['group_vaults'] = GroupVault::Representer::Index.new(group_vaults).to_hash
    end

    def assign_groups!(_options, serialized_model:, current_user:, **)
      groups = current_user.admin? ? current_user.admins_groups : current_user.leads_groups
      serialized_model['groups'] = Group::Representer::ShortIndex.new(groups).to_hash
    end

    def assign_user_vaults!(_options, model:, serialized_model:, **)
      user_vaults = UserVault.where(vault: model)
      serialized_model['user_vaults'] = UserVault::Representer::Index.new(user_vaults).to_hash
    end

    def assign_users!(_options, serialized_model:, current_user:, **)
      users = current_user.admin? ? current_user.admins_users : current_user.leads_users
      if current_user.support?
        users = current_user.support_users
      end
      serialized_model['users'] = User::Representer::Index.new(users).to_hash
    end
  end
end