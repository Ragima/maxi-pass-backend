# frozen_string_literal: true

module GroupUser::Operation
  class Destroy < Trailblazer::Operation
    step :group_model!
    step :user_model!
    step Policy::Guard(:update_user_groups?)
    step Policy::Guard(:update_group_users?)
    success :process!
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

    def process!(options, group:, user:, **)
      options['model.response'] = :no_content
      group_ids = [*group.ancestor_ids, *group.descendant_ids, group.id]
      GroupUser.where(group: group_ids, user: user).destroy_all
    end

    def write_activity!(options, current_user:, group:, user:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.delete_user_from_group',
        action_type: 'Group',
        action_act: 'Delete User',
        actor_action: 'Deleted access for user',
        subj1_id: user.id,
        subj1_title: user.email,
        subj1_action: 'from group',
        subj2_id: group.id,
        subj2_title: group.name
      )
    end
  end
end
