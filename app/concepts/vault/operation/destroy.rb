# frozen_string_literal: true

module Vault::Operation
  class Destroy < Trailblazer::Operation
    step Model(Vault, :find_by, :id)
    step Policy::Pundit(Vault::Policy::VaultPolicy, :destroy?)
    step :destroy!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def destroy!(options, model:, **)
      options['model.response'] = :no_content
      model.destroy
      result = Result.new(!model.persisted?, {})
      result.success?
    end

    def write_activity!(options, current_user:, model:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.delete_vault',
        action_type: 'Vault',
        action_act: 'Delete',
        actor_action: 'Deleted vault',
        subj1_id: model.id,
        subj1_title: model.title,
        params: { vault_is_shared: model.is_shared }
      )
    end
  end
end
