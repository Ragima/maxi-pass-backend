# frozen_string_literal: true

module User::Operation
  class Index < Trailblazer::Operation
    step Policy::Pundit(User::Policy::UserPolicy, :index?)
    step :define_scope!
    step :model!
    success :serialized_model!
    step :assign_group_users!
    step :assign_groups!
    step :assign_invitations!

    def define_scope!(options, current_user:, **)
      options[:users_scope] = users_scope = if current_user.admin?
                                              lambda(&:admins_users)
                                            elsif current_user.lead?
                                              lambda(&:leads_users)
                                            end
      !users_scope.nil?
    end

    def model!(options, current_user:, users_scope:, **)
      options[:model] = model = users_scope.call(current_user)
                                           .where(invitation_token: nil)
                                           .where.not(id: current_user.id)
                                           .order(role_id: :asc, first_name: :asc)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      serialized_model = User::Representer::Index.new(model).to_hash
      options[:serialized_model] = serialized_model
    end

    def assign_group_users!(options, model:, serialized_model:, **)
      options[:group_users] = group_users = GroupUser.where(user_id: model.ids)
      serialized_model['group_users'] = GroupUser::Representer::Index.new(group_users).to_hash
    end

    def assign_groups!(_options, group_users:, current_user:, serialized_model:, **)
      user_groups = current_user.admin? ? current_user.admins_groups : current_user.leads_groups
      groups = Group.where(id: user_groups.ids & group_users.pluck(:group_id))
      serialized_model['groups'] = Group::Representer::ShortIndex.new(groups).to_hash
    end

    def assign_invitations!(_options, serialized_model:, current_user:, **)
      invitations = current_user.team.users.where.not(invitation_token: nil)
      serialized_model['invitations'] = User::Representer::Invitations.new(invitations).to_hash
    end
  end
end
