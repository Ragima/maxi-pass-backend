# frozen_string_literal: true

module Vault::Operation
  class Create < Trailblazer::Operation
    step Model(Vault, :new)
    success :assign_additional_attributes!
    step Policy::Pundit(Vault::Policy::VaultPolicy, :create?)
    step Contract::Build(constant: Vault::Contract::Create)
    step Contract::Validate(key: :vault)
    step Contract::Persist()
    success :generate_admin_keys!
    step :generate_user_keys!
    success :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def assign_additional_attributes!(_options, model:, current_user:, **)
      model.assign_attributes(team: current_user.team, is_shared: true, user: current_user, admin_keys: {})
    end

    def generate_admin_keys!(options, model:, current_user:, **)
      options[:encoder] = encoder = Encoder.new(current_user)
      options[:vault_key] = vault_key = encoder.generate_sym_key(current_user)
      encoder.update_vault_key_for_admin_users(current_user, model, vault_key)
    end

    def generate_user_keys!(_options, model:, vault_key:, encoder:, current_user:, **)
      return true if current_user.admin?

      encrypted_vault_key = encoder.encrypt_sym_key(current_user, vault_key)
      UserVault.create(vault: model, user: current_user, vault_key: encrypted_vault_key, vault_writer: true)
    end

    def serialized_model!(options, model:, current_user:, **)
      serialized_vault = Vault::Representer::Show.new(model).to_hash
      serialized_vault['data'][:updatable] = Vault::Policy::VaultPolicy.new(current_user, model).change_vault_items?
      options[:serialized_model] = serialized_vault
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.create_vault',
        action_type: 'Vault',
        action_act: 'Create',
        actor_action: 'created vault',
        subj1_id: model.id,
        subj1_title: model.title,
        params: { vault_is_shared: model.is_shared }
      )
    end
  end
end
