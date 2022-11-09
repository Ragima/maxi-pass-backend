# frozen_string_literal: true

module UserVault::Policy
  class UserVaultPolicy < ApplicationPolicy
    include Users::Concerns::Role

    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def update_user_vaults?
      model.team_name = user.team_name && !model.role_admin? && (user.admin? || user.user_lead?(model))
    end

    def update_vault_users?
      model.team_name = user.team_name && (user.admin? || user.vault_lead?(model))
    end

  end
end