# frozen_string_literal: true

module VaultItem::Policy
  class VaultItemPolicy < ApplicationPolicy
    attr_reader :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def show?
      user.vault_item_writer?(model)
    end

    def create?
      user.vault_item_writer?(model)
    end

    def update?
      user.vault_item_writer?(model)
    end

    def destroy?
      user.vault_item_writer?(model)
    end

    def copy?
      user.vault_item_writer?(model)
    end

    def move?
      user.vault_item_writer?(model)
    end
  end
end
