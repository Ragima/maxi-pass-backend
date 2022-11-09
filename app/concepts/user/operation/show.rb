# frozen_string_literal: true

module User::Operation
  class Show < Trailblazer::Operation
    step Model(User, :find_by, :id)
    step Policy::Pundit(User::Policy::UserPolicy, :show?)
    step :serialized_model!
    step :assign_group_users!
    step :assign_user_vaults!
    step :assign_group_vaults!
    step :assign_groups!
    step :assign_vaults!
    step :assign_groups!

    def serialized_model!(options, model:, **)
      serialized_model = User::Representer::Show.new(model).to_hash
      options[:serialized_model] = serialized_model
    end

    def assign_group_users!(options, model:, serialized_model:, **)
      options[:group_users] = group_users = GroupUser.where(user: model)
      serialized_model['group_users'] = GroupUser::Representer::Index.new(group_users).to_hash
    end

    def assign_user_vaults!(_options, model:, serialized_model:, **)
      user_vaults = UserVault.where(user: model)
      serialized_model['user_vaults'] = UserVault::Representer::Index.new(user_vaults).to_hash
    end

    def assign_group_vaults!(_options, group_users:, serialized_model:, **)
      groups = Group.where(id: group_users.pluck(:group_id))
      group_vaults = GroupVault.where(group_id: groups.pluck(:id))
      serialized_model['group_vaults'] = GroupVault::Representer::Index.new(group_vaults).to_hash
    end

    def assign_vaults!(_options, serialized_model:, current_user:, **)
      vaults = current_user.admin? ? current_user.admins_vaults_without_personal : current_user.users_vaults_without_personal
      serialized_model['vaults'] = Vault::Representer::ShortIndex.new(vaults).to_hash
    end

    def assign_groups!(_options, serialized_model:, current_user:, **)
      groups = current_user.admin? ? current_user.admins_groups : current_user.leads_groups
      serialized_model['groups'] = Group::Representer::ShortIndex.new(groups).to_hash
    end
  end
end