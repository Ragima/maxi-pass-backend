# frozen_string_literal: true

module Api::V1
  class DocumentsController < ApplicationController
    include KeysConcern

    before_action :decrypt_temp_phrase
    before_action :find_vault, only: %i[show create update destroy]
    before_action :find_vault_item, only: %i[show create update destroy]
    before_action :find_document, only: %i[show update destroy]
    before_action :decrypt_file, only: :show

    def show
      authorize @vault, :show_vault_items?, policy_class: Vault::Policy::VaultPolicy
      send_data(@file_content[:content], filename: @file_content[:file_name])
    end

    def create
      authorize @vault, :show_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: Document::Operation::Create,
               options: { current_user: current_user, vault_item: @vault_item }
    end

    def update
      authorize @vault, :show_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: Document::Operation::Update,
               options: { current_user: current_user, vault_item: @vault_item }
    end

    def destroy
      authorize @vault, :show_vault_items?, policy_class: Vault::Policy::VaultPolicy
      endpoint operation: Document::Operation::Destroy,
               options: { current_user: current_user, vault_item: @vault_item }
    end

    protected

    def entity_class
      ServerItem
    end

    def entity_sym
      :server_item
    end

    private

    def find_vault_item
      @vault_item = @vault.vault_items.find_by(type: entity_class.to_s, id: params[:server_item_id])
      head(:not_found) if @vault_item.nil?
    end

    def find_vault
      @vault = Vault.find_by(id: params[:vault_id])
      head(:not_found) if @vault.nil?
    end

    def decrypt_file
      result = Document::Operation::Show.call(current_user: current_user, vault_item: @vault_item, params: params)
      @file_content = result['model.response']
      head(:not_found) if result.failure?
    end

    def find_document
      @document = @vault_item.documents.find_by(id: params[:id])
      head(:not_found) if @document.nil?
    end
  end
end