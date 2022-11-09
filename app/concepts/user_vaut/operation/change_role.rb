# frozen_string_literal: true

module UserVault::Operation
  class ChangeRole < Trailblazer::Operation
    step :user_model!
    step :vault_model!
    step Policy::Guard(:update_user_vaults?)
    step Policy::Guard(:update_vault_users?)
    step :model!
    step Contract::Build(constant: UserVault::Contract::ChangeRole)
    step Contract::Validate()
    step Contract::Persist()
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

    def model!(options, user:, vault:, **)
      options[:model] = model = UserVault.find_by(user: user, vault: vault)
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = UserVault::Representer::Show.new(model).to_hash
    end

    def write_activity!(options, current_user:, vault:, user:, **)
      options[:activity] = ActivityService.new(current_user).call(
        key: 'user.change_vault_role',
        action_type: 'Vault',
        action_act: 'Change Role',
        actor_action: 'changed role',
        subj1_id: user.id,
        subj1_title: user.email,
        subj1_action: "to #{user.role_id}",
        subj2_id: vault.id,
        subj2_title: vault.title,
        params: { vault_is_shared: vault.is_shared }
      )
    end
  end
end
