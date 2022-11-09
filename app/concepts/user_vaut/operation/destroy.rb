# frozen_string_literal: true

module UserVault::Operation
  class Destroy < Trailblazer::Operation
    step :user_model!
    step :vault_model!
    step Policy::Guard(:update_user_vaults?)
    step Policy::Guard(:update_vault_users?)
    success :process!
    success :write_activity!
    success Nested(AdminMailer::Operation::Create)

    def user_model!(options, params:, current_user:, **)
      options[:user] = model = current_user.team.users.find_by(id: params[:user_id])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def vault_model!(options, params:, current_user:, **)
      options[:vault] = model = current_user.team.vaults.find_by(id: params[:vault_id], is_shared: true)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def update_user_vaults?(_options, user:, current_user:, **)
      UserVault::Policy::UserVaultPolicy.new(current_user, user).update_user_vaults?
    end

    def update_vault_users?(_options, group:, current_user:, **)
      UserVault::Policy::UserVaultPolicy.new(current_user, group).update_vault_users?
    end

    def process!(options, vault:, user:, **)
      options['model.response'] = :no_content
      user_vault = UserVault.find_by(user: user, vault: vault)
      return true if user_vault.nil?

      user_vault.destroy
      result = Result.new(!user_vault.persisted?, {})
      result.success?
    end

    def write_activity!(options, current_user:, vault:, user:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.delete_user_from_vault',
        action_type: 'Vault',
        action_act: 'Delete User',
        actor_action: 'Deleted user',
        subj1_id: user.id,
        subj1_title: user.email,
        subj1_action: 'from vault',
        subj2_id: vault.id,
        subj2_title: vault.title,
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
