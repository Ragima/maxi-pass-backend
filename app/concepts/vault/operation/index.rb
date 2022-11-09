# frozen_string_literal: true

module Vault::Operation
  class Index < Trailblazer::Operation
    success :define_scope!
    step :model!
    success :serialized_model!
    step :assign_group_vaults!
    success :assign_groups!
    success :assign_users!

    def define_scope!(options, current_user:, **)
      options[:vaults_scope] = if current_user.admin?
                                 lambda(&:admins_vaults)
                               else
                                 lambda(&:users_vaults)
                               end
    end

    def model!(options, vaults_scope:, current_user:, **)
      options[:model] = model = vaults_scope.call(current_user)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Vault::Representer::Index.new(model).to_hash
    end

    def assign_group_vaults!(options, serialized_model:, model:, **)
      options[:group_vaults] = group_vaults = GroupVault.where(vault_id: model.ids)
      serialized_model['group_vaults'] = GroupVault::Representer::Index.new(group_vaults).to_hash
    end

    def assign_groups!(_options, group_vaults:, serialized_model:, current_user:, **)
      user_groups = current_user.admin? ? current_user.admins_groups : current_user.leads_groups
      groups = Group.where(id: group_vaults.pluck(:group_id) & user_groups.pluck(:id))
      serialized_model['groups'] = Group::Representer::ShortIndex.new(groups).to_hash
    end

    def assign_users!(_options, serialized_model:, current_user:, **)
      users = current_user.admin? ? current_user.admins_users : current_user.leads_users
      serialized_model['users'] = User::Representer::Index.new(users).to_hash
    end
  end
end
