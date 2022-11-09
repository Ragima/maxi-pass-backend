# frozen_string_literal: true

module VaultItem::Operation
  class Update < Trailblazer::Operation
    step :define_entity_sym!
    step VaultItem::Callable::ExtractParams
    step :model!
    step Contract::Build(constant: VaultItem::Contract::Update)
    step Contract::Validate(skip_extract: true)
    success :encrypt_content_and_assign!
    step Policy::Pundit(VaultItem::Policy::VaultItemPolicy, :update?)
    step Contract::Persist()
    success :serialized_model!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def define_entity_sym!(options, **)
      options[:entity_sym] = entity_sym
    end

    def model!(options, vault:, params:, **)
      options[:model] = model = vault.vault_items.find_by(type: entity_class.to_s, id: params[:id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def encrypt_content_and_assign!(options, model:, current_user:, vault:, **)
      encrypted_content = Encoder.new(current_user).update_encrypted_content(options['contract.default.closed_params'], vault)
      model.assign_attributes(options['contract.default.params'].merge(content: encrypted_content))
    end

    def serialized_model!(options, model:, current_user:, **)
      serialized_vault_item = VaultItem::Representer::Show.new(model).to_hash(user_options: { current_user: current_user })
      serialized_vault_item['data'][:content] = options['contract.default.closed_params']
      options[:serialized_model] = serialized_vault_item
    end

    def write_activity!(options, current_user:, model:, vault:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: "user.update_#{entity_sym.to_s}",
        actor_action: "updated #{entity_sym.to_s.humanize.downcase}",
        action_type: entity_class.to_s.underscore.humanize,
        action_act: 'Update',
        subj1_id: model.id,
        subj1_title: model.title,
        subj1_action: 'in vault',
        subj2_id: vault.id,
        subj2_title: vault.title,
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
