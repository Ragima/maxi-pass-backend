# frozen_string_literal: true

module GroupUser::Operation
  class ChangeRole < Trailblazer::Operation
    step :group_model!
    step :user_model!
    step Policy::Guard(:update_user_groups?)
    step Policy::Guard(:update_group_users?)
    step :model!
    step Contract::Build(constant: GroupUser::Contract::ChangeRole)
    step Contract::Validate()
    step Contract::Persist()
    step :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def group_model!(options, params:, current_user:, **)
      options[:group] = model = current_user.team.groups.find_by(id: params[:group_id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def user_model!(options, params:, current_user:, **)
      options[:user] = model = current_user.team.users.find_by(id: params[:user_id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def update_user_groups?(_options, user:, current_user:, **)
      GroupUser::Policy::GroupUserPolicy.new(current_user, user).update_user_groups?
    end

    def update_group_users?(_options, group:, current_user:, **)
      GroupUser::Policy::GroupUserPolicy.new(current_user, group).update_group_users?
    end

    def model!(options, group:, user:, **)
      options[:model] = model = GroupUser.find_by(group: group, user: user)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = GroupUser::Representer::Show.new(model).to_hash
    end

    def write_activity!(options, current_user:, group:, user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.change_group_role',
        action_type: 'Group',
        action_act: 'Change Role',
        actor_action: 'changed role',
        subj1_id: user.id,
        subj1_title: user.email,
        subj1_action: "to #{model.role} in",
        subj2_id: group.id,
        subj2_title: group.name
      )
    end
  end
end
