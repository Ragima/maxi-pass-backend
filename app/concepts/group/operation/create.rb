# frozen_string_literal: true

module Group::Operation
  class Create < Trailblazer::Operation
    step Model(Group, :new)
    step Contract::Build(constant: Group::Contract::Create)
    success :find_parent!
    success :assign_additional_params!
    success :assign_additional_attributes!
    step Policy::Pundit(Group::Policy::GroupPolicy, :create?)
    step Contract::Validate(key: :group)
    step Contract::Persist()
    success :update_group_users_keys!
    step :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def find_parent!(options, current_user:, params:, **)
      options[:parent] = Group.find_by(team: current_user.team, id: params.dig(:group, :parent_group_id))
    end

    def assign_additional_params!(_options, params:, current_user:, **)
      params[:group][:team_name] = current_user.team_name
    end

    def assign_additional_attributes!(_options, model:, current_user:, parent:, **)
      model.assign_attributes(team: current_user.team, parent: parent, admin_keys: {})
    end

    def update_group_users_keys!(_options, model:, current_user:, **)
      encoder = Encoder.new(current_user)
      group_key = encoder.generate_sym_key(current_user)
      encoder.assign_group_admin_keys(model, group_key)
      unless current_user.admin?
        group_user = GroupUser.where(user: current_user, group: model).first_or_initialize
        encoder.assign_group_user_key(current_user, group_user, group_key)
        group_user.save
      end
      model.ancestors.find_each do |group|
        group.users.find_each do |user|
          group_user = GroupUser.where(user: user, group: model).first_or_initialize
          next unless group_user.group_key.blank?

          encoder.assign_group_user_key(user, group_user, group_key)
          group_user.save
        end
      end
    end

    def serialized_model!(options, model:, **)
      serialized_vault = Group::Representer::Show.new(model).to_hash
      options[:serialized_model] = serialized_vault
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.create_group',
        action_type: 'Group',
        action_act: 'Create',
        actor_action: 'created group',
        subj1_id: model.id,
        subj1_title: model.name
      )
    end
  end
end
