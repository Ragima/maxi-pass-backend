# frozen_string_literal: true

module Api::V1
  class VaultsController < ApplicationController
    include KeysConcern
    include SerializeObject

    before_action :decrypt_temp_phrase
    before_action :set_vault, only: %i[generate_report]
    before_action :set_user, only: %i[generate_report]

    def index
      endpoint operation: Vault::Operation::Index,
               options: { current_user: current_user }
    end

    def show
      endpoint operation: Vault::Operation::Show,
               options: { current_user: current_user }
    end

    def create
      endpoint operation: Vault::Operation::Create,
               options: { current_user: current_user }
    end

    def update
      endpoint operation: Vault::Operation::Update,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: Vault::Operation::Destroy,
               options: { current_user: current_user }
    end

    def vault_items
      endpoint operation: Vault::Operation::VaultItems,
               options: { current_user: current_user }
    end

    def generate_report
      authorize @vault
      ReportJob.perform_later(@vault.id, @user.id, current_user.id, "Vault")
      render json: { status: 200 }
    end

    private

    def set_vault
      @vault = @current_user.team.vaults.find_by(id: params[:vault_id])
      head(:not_found) if @vault.nil?
    end

    def set_user
      @user = @current_user.team.users.find_by(id: params[:user_id])
      head(:not_found) if @user.nil?
    end
  end
end
