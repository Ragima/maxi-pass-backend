# frozen_string_literal: true

module Group::Representer
  class ShortIndex < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: Group do
      property :id
      property :name
      property :parent_group_id
      property :created_at
      property :updated_at
    end
  end
end