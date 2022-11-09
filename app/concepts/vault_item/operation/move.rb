# frozen_string_literal: true

module VaultItem::Operation
  class Move < Trailblazer::Operation
    step :model!
    step Policy::Pundit(VaultItem::Policy::VaultItemPolicy, :copy?)
    success :check_target_vault!
    success :write_activity!
    step :move_item!
    success Nested(AdminMailer::Operation::Create)

    def model!(options, params:, vault:, **)
      options[:model] = model = vault.vault_items.find_by(type: entity_class.to_s, id: params["#{entity_sym}_id".to_sym])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def check_target_vault!(_options, model:, target_vault:, **)
      model.only_for_admins = false unless target_vault.is_shared
    end

    def move_item!(options, current_user:, model:, target_vault:, **)
      options['model.response'] = :no_content
      encoder = Encoder.new(current_user)
      decrypted_content = encoder.decrypted_content(model)
      content = decrypted_content.blank? ? nil : encoder.update_encrypted_content(decrypted_content, target_vault)
      model.assign_attributes(content: content, vault: target_vault)
      model.save
    end

    def write_activity!(options, current_user:, model:, vault:, target_vault:, **)
      options[:activity] = ActivityService.new(current_user).call(
        action_type: entity_class.to_s.underscore.humanize,
        action_act: 'Move',
        key: "user.move_#{entity_sym.to_s}",
        actor_action: "moved #{entity_sym.to_s.humanize.downcase}",
        subj1_id: model.id,
        subj1_title: model.title,
        subj1_action: 'from vault',
        subj2_id: vault.id,
        subj2_title: vault.title,
        subj2_action: 'to vault',
        subj3_id: target_vault.id,
        subj3_title: target_vault.title,
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
