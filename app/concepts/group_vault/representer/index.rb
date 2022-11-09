# frozen_string_literal: true

module GroupVault::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: GroupVault do
      property :id
      property :group_id
      property :vault_id
    end
  end
end