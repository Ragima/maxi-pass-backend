# frozen_string_literal: true

module Vault::Operation
  class Update < Trailblazer::Operation
    step Model(Vault, :find_by, :id)
    step Policy::Pundit(Vault::Policy::VaultPolicy, :update?)
    step Contract::Build(constant: Vault::Contract::Update)
    step Contract::Validate(key: :vault)
    step Contract::Persist()
    success :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def serialized_model!(options, model:, current_user:, **)
      serialized_vault = Vault::Representer::Show.new(model).to_hash
      serialized_vault['data'][:updatable] = Vault::Policy::VaultPolicy.new(current_user, model).change_vault_items?
      options[:serialized_model] = serialized_vault
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.update_vault',
        action_type: 'Vault',
        action_act: 'Update',
        actor_action: 'updated vault',
        subj1_id: model.id,
        subj1_title: model.title,
        params: { vault_is_shared: model.is_shared }
      )
    end
  end
end
