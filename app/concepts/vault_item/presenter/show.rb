# frozen_string_literal: true

module VaultItem::Representer
  class Show < Representable::Decorator
    include Representable::Hash
    nested :data do
      property :id
      property :title
      property :vault_id
      property :tags
      property :updatable,
               getter: ->(represented:, user_options:, **) { Vault::Policy::VaultPolicy.new(user_options[:current_user], represented.vault).change_vault_items? }
      property :has_access,
               getter: ->(represented:, user_options:, **) { Vault::Policy::VaultPolicy.new(user_options[:current_user], represented.vault).change_vault_items? }
      property :entity_type, exec_context: :decorator
      property :created_at
      property :updated_at
      property :only_for_admins
      collection :documents, if: ->(options) { options[:represented].type.eql?('ServerItem') }, decorator: Document::Representer::Show

      def entity_type
        represented.type
      end
    end
  end
end