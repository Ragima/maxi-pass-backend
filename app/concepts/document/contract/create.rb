# frozen_string_literal: true

module Document::Contract
  class Create < Reform::Form
    property :id
    property :file

    validates :file, presence: true
  end
end