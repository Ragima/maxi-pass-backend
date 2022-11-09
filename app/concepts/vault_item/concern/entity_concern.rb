# frozen_string_literal: true

module VaultItem::Concern
  module EntityConcern
    extend ActiveSupport::Concern

    protected

    def entity_class
      VaultItem
    end

    def entity_sym
      :vault_item
    end
  end
end