# frozen_string_literal: true

module VaultItem::Operation
  class Destroy < Trailblazer::Operation
    step :model!
    step Policy::Pundit(VaultItem::Policy::VaultItemPolicy, :destroy?)
    step :destroy!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def model!(options, vault:, params:, **)
      options[:model] = model = vault.vault_items.find_by(type: entity_class.to_s, id: params[:id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def destroy!(options, model:, **)
      options['model.response'] = :no_content
      model.destroy
      result = Result.new(!model.persisted?, {})
      result.success?
    end

    def write_activity!(options, current_user:, model:, vault:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: "user.delete_#{entity_sym}",
        action_type: entity_class.to_s.underscore.humanize,
        action_act: 'Delete',
        actor_action: "Deleted #{entity_sym.to_s.humanize.downcase}",
        subj1_id: model.id,
        subj1_title: model.title,
        subj1_action: 'in vault',
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
