# frozen_string_literal: true

module CreditCardItem::Concern
  module EntityConcern
    extend ActiveSupport::Concern

    private

    def entity_class
      CreditCardItem
    end

    def entity_sym
      :credit_card_item
    end
  end
end