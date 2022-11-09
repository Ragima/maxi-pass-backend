# frozen_string_literal: true

module GroupVault::Operation
  class Destroy < Trailblazer::Operation
    step :group_model!
    step :vault_model!
    step Policy::Guard(:update_group_vaults?)
    step Policy::Guard(:update_vault_groups?)
    step :process!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def group_model!(options, params:, current_user:, **)
      options[:group] = model = current_user.team.groups.find_by(id: params[:group_id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def vault_model!(options, params:, current_user:, **)
      options[:vault] = model = current_user.team.vaults.find_by(id: params[:vault_id], is_shared: true)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def update_group_vaults?(_options, group:, current_user:, **)
      GroupVault::Policy::GroupVaultPolicy.new(current_user, group).update_group_vaults?
    end

    def update_vault_groups?(_options, vault:, current_user:, **)
      GroupVault::Policy::GroupUserPolicy.new(current_user, vault).update_vault_groups?
    end

    def process!(options, group:, vault:, **)
      options['model.response'] = :no_content
      group_vault = GroupVault.find_by(group: group, vault: vault)
      return true if group_vault.nil?

      group_vault.destroy
      result = Result.new(!group_vault.persisted?, {})
      result.success?
    end

    def write_activity!(options, current_user:, group:, vault:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.deleted_vault_from_group',
        action_type: 'Group',
        action_act: 'Delete Vault',
        actor_action: 'Deleted Vault',
        subj1_id: vault.id,
        subj1_title: vault.title,
        subj1_action: 'from group',
        subj2_id: group.id,
        subj2_title: group.name,
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
