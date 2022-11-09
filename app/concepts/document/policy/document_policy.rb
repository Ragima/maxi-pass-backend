# frozen_string_literal: true

module Document::Policy
  class DocumentPolicy < ApplicationPolicy
    attr_reader :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def show?
      user.vault_item_writer?(model.vault_item)
    end

    def create?
      user.vault_item_writer?(model.vault_item)
    end

    def update?
      user.vault_item_writer?(model.vault_item)
    end

    def destroy?
      user.vault_item_writer?(model.vault_item)
    end
  end
end
