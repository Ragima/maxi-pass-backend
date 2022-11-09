# frozen_string_literal: true

module Vault::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: Vault do
      property :id
      property :title
      property :description
      property :is_shared
      property :created_at
      property :updated_at
      property :items, exec_context: :decorator

      def items
        represented.vault_items.size
      end
    end
  end
end