# frozen_string_literal: true

module Document::Contract
  class Update < Reform::Form
    property :id
    property :file

    validates :file, presence: true
  end
end