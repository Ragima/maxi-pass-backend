# frozen_string_literal: true

module UserVault::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :id
      property :user_id
      property :vault_id
      property :role
    end
  end
end