# frozen_string_literal: true

module Api::V1
  class ServerItemsController < VaultItemsController

    protected

    def entity_class
      ServerItem
    end

    def entity_sym
      :server_item
    end
  end
end