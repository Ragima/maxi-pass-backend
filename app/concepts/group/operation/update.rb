# frozen_string_literal: true

module Group::Operation
  class Update < Trailblazer::Operation
    step Model(Group, :find_by, :id)
    step Policy::Pundit(Group::Policy::GroupPolicy, :update?)
    step Contract::Build(constant: Group::Contract::Update)
    step Contract::Validate(key: :group)
    step Contract::Persist()
    success :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def serialized_model!(options, model:, **)
      options[:serialized_model] = Group::Representer::Show.new(model).to_hash
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.update_group',
        action_type: 'Group',
        action_act: 'Update',
        actor_action: 'updated group',
        subj1_id: model.id,
        subj1_title: model.name
      )
    end
  end
end
