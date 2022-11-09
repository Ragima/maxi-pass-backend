# frozen_string_literal: true

module ServerItem::Concern
  module EntityConcern
    extend ActiveSupport::Concern

    protected

    def entity_class
      ServerItem
    end

    def entity_sym
      :server_item
    end
  end
end