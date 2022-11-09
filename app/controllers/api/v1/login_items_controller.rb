# frozen_string_literal: true

module Api::V1
  class LoginItemsController < VaultItemsController

    protected

    def entity_class
      LoginItem
    end

    def entity_sym
      :login_item
    end
  end
end