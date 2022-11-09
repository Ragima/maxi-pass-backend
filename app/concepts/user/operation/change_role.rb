# frozen_string_literal: true

module User::Operation
  class ChangeRole < Trailblazer::Operation
    step Model(User, :find_by_user_id, :user_id)
    step Policy::Pundit(User::Policy::UserPolicy, :change_role?)
    step Contract::Build(constant: User::Contract::ChangeRole)
    step Contract::Validate()
    step Contract::Persist()
    step :assign_admin_role!
    success :update_vaults_and_groups_keys!
    step :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def assign_admin_role!(_options, params:, model:, **)
      model.role_id = params[:role_id]
    end

    def update_vaults_and_groups_keys!(_options, model:, current_user:, **)
      return false unless model.save

      encoder = Encoder.new(current_user)
      encoder.update_role_to_admin(model)
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = User::Representer::Show.new(model).to_hash
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.change_role',
        action_type: 'User',
        action_act: 'Change Role',
        actor_action: 'changed role',
        subj1_id: model.id,
        subj1_title: model.email
      )
    end
  end
end
