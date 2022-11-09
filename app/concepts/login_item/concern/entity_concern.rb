# frozen_string_literal: true

module LoginItem::Concern
  module EntityConcern
    extend ActiveSupport::Concern

    protected

    def entity_class
      LoginItem
    end

    def entity_sym
      :login_item
    end
  end
end