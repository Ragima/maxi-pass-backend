# frozen_string_literal: true

module GroupUser::Operation
  class Create < Trailblazer::Operation
    step :group_model!
    step :user_model!
    step Policy::Guard(:update_user_groups?)
    step Policy::Guard(:update_group_users?)
    success :process!
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

    def process!(options, group:, user:, current_user:, **)
      encoder = Encoder.new(current_user)
      group_users = []
      [group, *group.descendants].each do |self_or_descendant|
        group_user = GroupUser.where(user: user, group: self_or_descendant).first_or_initialize
        next unless group_user.group_key.blank?

        group_key = encoder.decrypted_group_key(self_or_descendant)
        encoder.assign_group_user_key(user, group_user, group_key)
        group_user.save
        group_users.push(group_user)
      end
      options[:model] = group_users
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = GroupUser::Representer::Index.new(model).to_hash
    end

    def write_activity!(options, current_user:, group:, user:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.add_user',
        action_type: 'Group',
        action_act: 'Add User',
        actor_action: 'added user',
        subj1_id: user.id,
        subj1_title: user.email,
        subj1_action: 'to group',
        subj2_id: group.id,
        subj2_title: group.name
      )
    end
  end
end
