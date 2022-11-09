# frozen_string_literal: true

module Vault::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :id
      property :title
      property :description
      property :is_shared
      property :created_at
      property :updated_at
    end
  end
end