# frozen_string_literal: true

module Group::Operation
  class Show < Trailblazer::Operation
    step Model(Group, :find_by, :id)
    step Policy::Pundit(Group::Policy::GroupPolicy, :show?)
    success :serialized_model!
    step :assign_group_vaults!
    step :assign_group_users!
    step :assign_vaults!
    step :assign_groups!
    step :assign_user_vaults!
    step :assign_users!

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Group::Representer::Show.new(model).to_hash
    end

    def assign_group_vaults!(_options, model:, serialized_model:, **)
      group_vaults = GroupVault.where(group: model)
      serialized_model['group_vaults'] = GroupVault::Representer::Index.new(group_vaults).to_hash
    end

    def assign_group_users!(_options, model:, serialized_model:, **)
      group_users = GroupUser.where(group: model)
      serialized_model['group_users'] = GroupUser::Representer::Index.new(group_users).to_hash
    end

    def assign_vaults!(_options, serialized_model:, current_user:, **)
      vaults = current_user.admin? ? current_user.admins_vaults_without_personal : current_user.users_vaults_without_personal
      serialized_model['vaults'] = Vault::Representer::ShortIndex.new(vaults).to_hash
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
      serialized_model['users'] = User::Representer::Index.new(users).to_hash
    end
  end
end