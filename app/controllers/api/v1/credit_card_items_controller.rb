# frozen_string_literal: true

module Api::V1
  class CreditCardItemsController < VaultItemsController

    protected

    def entity_class
      CreditCardItem
    end

    def entity_sym
      :credit_card_item
    end
  end
end