# frozen_string_literal: true

module UserVault::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: UserVault do
      property :id
      property :user_id
      property :vault_id
      property :vault_writer
    end
  end
end