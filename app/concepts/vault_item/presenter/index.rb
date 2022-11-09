# frozen_string_literal: true

module VaultItem::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: VaultItem do
      property :id
      property :title
      property :vault_id
      property :tags
      property :entity_type, exec_context: :decorator
      property :created_at
      property :updated_at

      def entity_type
        represented.type
      end
    end
  end
end