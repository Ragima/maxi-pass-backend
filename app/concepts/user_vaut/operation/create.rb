# frozen_string_literal: true

module UserVault::Operation
  class Create < Trailblazer::Operation
    step :user_model!
    step :vault_model!
    step Policy::Guard(:update_user_vaults?)
    step Policy::Guard(:update_vault_users?)
    step :process!
    step :serialized_model!
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

    def update_vault_users?(_options, vault:, current_user:, **)
      UserVault::Policy::UserVaultPolicy.new(current_user, vault).update_vault_users?
    end

    def process!(options, user:, vault:, current_user:, **)
      encoder = Encoder.new(current_user)
      options[:model] = user_vault = UserVault.where(vault: vault, user: user).first_or_initialize
      return true unless user_vault.vault_key.blank?

      encoder.update_user_vaults_keys(user, vault, user_vault)
      user_vault.save
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = UserVault::Representer::Index.new([model]).to_hash
    end

    def write_activity!(options, current_user:, vault:, user:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.add_user_to_vault',
        action_type: 'Vault',
        action_act: 'Add User',
        actor_action: 'added user',
        subj1_id: user.id,
        subj1_title: user.email,
        subj1_action: 'to vault',
        subj2_id: vault.id,
        subj2_title: vault.title,
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
