# frozen_string_literal: true

module Vault::Representer
  class ShortIndex < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: Vault do
      property :id
      property :title
      property :description
      property :is_shared
      property :created_at
      property :updated_at
    end
  end
end