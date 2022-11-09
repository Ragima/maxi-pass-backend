# frozen_string_literal: true

module VaultItem::Operation
  class Show < Trailblazer::Operation
    step :model!
    step Policy::Pundit(VaultItem::Policy::VaultItemPolicy, :show?)
    success :serialized_model!
    step :assign_vaults!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def model!(options, vault:, params:, **)
      options[:model] = model = vault.vault_items.find_by(type: entity_class.to_s, id: params[:id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, current_user:, **)
      serialized_vault_item = VaultItem::Representer::Show.new(model).to_hash(user_options: { current_user: current_user })
      serialized_vault_item['data'][:content] = Encoder.new(current_user).decrypted_content(model)
      options[:serialized_model] = serialized_vault_item
    end

    def assign_vaults!(_options, serialized_model:, current_user:, **)
      vaults = current_user.admin? ? current_user.admins_vaults_without_personal : current_user.users_vaults_without_personal
      serialized_model['vaults'] = Vault::Representer::ShortIndex.new(vaults).to_hash
    end

    def write_activity!(options, current_user:, model:, vault:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: "user.read_#{entity_sym.to_s}",
        action_act: 'Read',
        actor_action: "read #{entity_sym.to_s.humanize.downcase}",
        action_type: entity_class.to_s.underscore.humanize,
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
