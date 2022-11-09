# frozen_string_literal: true

module User::Operation
  class Restore < Trailblazer::Operation
    step Policy::Pundit(User::Policy::UserPolicy, :restore?)
    step Model(User, :find_by_user_id, :user_id)
    success :delete_personal_vault!
    step :define_encoder!
    success :restore_groups_access!
    success :restore_vaults_access!
    success :create_personal_vault!
    step :user_restored!

    def delete_personal_vault!(_options, model:, **)
      Vault.find_by(user: model, is_shared: [nil, false])&.destroy
    end

    def define_encoder!(options, current_user:, **)
      options[:encoder] = Encoder.new(current_user)
    end

    def restore_groups_access!(_options, model:, current_user:, encoder:, **)
      if model.admin?
        current_user.team.groups.find_each do |group|
          group_admin_key = group.group_admin_keys.where(user: model).first_or_initialize
          group_admin_key.update_attributes(key: encoder.encrypt_sym_key(model, encoder.decrypted_group_key_for_admin(group)))
        end
      end
      model.group_users.find_each do |group_user|
        group_user.update_attributes(group_key: encoder.encrypt_sym_key(model, encoder.decrypted_group_key_for_admin(group_user.group)))
      end
    end

    def restore_vaults_access!(_options, model:, current_user:, encoder:, **)
      if model.admin?
        current_user.team.vaults.find_each do |vault|
          vault_admin_key = vault.vault_admin_keys.where(user: model).first_or_initialize
          vault_admin_key.update_attributes(key: encoder.encrypt_sym_key(model, encoder.decrypted_vault_key_for_admin(vault)))
        end
      end
      model.user_vaults.find_each do |user_vault|
        user_vault.update_attributes(vault_key: encoder.encrypt_sym_key(model, encoder.decrypted_vault_key_for_admin(user_vault.vault)))
      end
    end

    def create_personal_vault!(_options, model:, **)
      Vault.create_personal_vault(model) if model.team.support_personal_vaults
    end

    def user_restored!(_options, model:, **)
      model.update_attributes(reset_password_token: nil, reset_password_sent_at: nil, reset_pass: false, change_pass: false)
    end
  end
end
