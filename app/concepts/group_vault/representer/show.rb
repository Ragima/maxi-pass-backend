# frozen_string_literal: true

module GroupVault::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :id
      property :group_id
      property :vault_id
    end
  end
end