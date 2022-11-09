# frozen_string_literal: true

class VaultItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :title, :vault_id, :tags
  attribute :entity_type do |object|
    object.type
  end
end
