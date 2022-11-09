# frozen_string_literal: true

module Vault::Operation
  class VaultItems < Trailblazer::Operation
    step :vault_model!
    step Policy::Guard(:show_items?)
    step :model!
    step :serialized_model!

    def vault_model!(options, params:, current_user:, **)
      options[:vault] = model =
                          current_user.team.vaults.find_by(id: params[:vault_id], is_shared: true) ||
                          Vault.find_by(user: current_user, is_shared: [nil, false])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def show_items?(_options, current_user:, vault:, **)
      Vault::Policy::VaultPolicy.new(current_user, vault).show_vault_items?
    end

    def model!(options, vault:, current_user:, **)
      options[:model] = model = current_user.admin? ? vault.vault_items : vault.vault_items.where(only_for_admins: [nil, false])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def serialized_model!(options, current_user:, vault:, model:, **)
      serialized_model = VaultItem::Representer::Index.new(model).to_hash
      serialized_vault = Vault::Representer::Show.new(vault).to_hash
      serialized_vault['data']['updatable'] = Vault::Policy::VaultPolicy.new(current_user, vault).change_vault_items?
      serialized_model['vault'] = serialized_vault
      options[:serialized_model] = serialized_model
    end
  end
end
