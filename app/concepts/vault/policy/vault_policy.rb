# frozen_string_literal: true

module Vault::Policy
  class VaultPolicy < ApplicationPolicy
    attr_reader :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def show?
      user.vault_admin_or_lead?(model)
    end

    def create?
      (user.admin? || user.lead?) && model.is_shared
    end

    def update?
      user.vault_admin_or_lead?(model) && model.is_shared
    end

    def destroy?
      return false if user.support?
      user.vault_admin_or_lead?(model) && model.is_shared
    end

    def show_vault_items?
      user.vault_reader?(model)
    end

    def change_vault_items?
      user.vault_writer?(model)
    end
  end
end