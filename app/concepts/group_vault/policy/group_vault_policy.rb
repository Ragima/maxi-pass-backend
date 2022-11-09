# frozen_string_literal: true

module GroupVault::Policy
  class GroupVaultPolicy < ApplicationPolicy
    include Users::Concerns::Role

    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def update_group_vaults?
      user.admin? || user.group_lead?(model)
    end

    def update_vault_groups?
      user.admin? || user.vault_lead?(model)
    end

  end
end