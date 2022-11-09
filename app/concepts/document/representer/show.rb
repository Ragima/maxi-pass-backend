# frozen_string_literal: true

module Document::Representer
  class Show < Representable::Decorator
    include Representable::Hash
    nested :data do
      property :id
      property :file, getter: ->(represented:, **) { represented.file.original_filename }
    end
  end
end