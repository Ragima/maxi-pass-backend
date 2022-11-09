# frozen_string_literal: true

module Api::V1
  class VaultItemsController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase
    before_action :find_vault, only: %i[show create update destroy copy move]
    before_action :find_target_vault, only: %i[copy move]
    before_action :find_vault_item, only: %i[show update destroy]

    def show
      authorize @vault, :show_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: entity_class::Operation::Show,
               options: { current_user: current_user, vault: @vault }
    end

    def create
      authorize @vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: entity_class::Operation::Create,
               options: { current_user: current_user, vault: @vault }
    end

    def update
      authorize @vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: entity_class::Operation::Update,
               options: { current_user: current_user, vault: @vault }
    end

    def destroy
      authorize @vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: entity_class::Operation::Destroy,
               options: { current_user: current_user, vault: @vault }
    end

    def copy
      authorize @vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      authorize @target_vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: entity_class::Operation::Copy,
               options: { current_user: current_user, vault: @vault, target_vault: @target_vault }
    end

    def move
      authorize @target_vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      authorize @target_vault, :change_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: entity_class::Operation::Move,
               options: { current_user: current_user, vault: @vault, target_vault: @target_vault }
    end

    protected

    def entity_class
      VaultItem
    end

    def entity_sym
      :vault_item
    end

    private

    def find_vault_item
      @vault_item = @vault.vault_items.find_by(type: entity_class.to_s, id: params[:id])
      head(:not_found) if @vault_item.nil?
    end

    def find_vault
      @vault = Vault.find_by(id: params[:vault_id])
      head(:not_found) if @vault.nil?
    end

    def find_target_vault
      @target_vault = Vault.find_by(id: params[:target_vault_id])
      head(:not_found) if @target_vault.nil?
    end

  end
end
