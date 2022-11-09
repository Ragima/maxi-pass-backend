# frozen_string_literal: true

module Password::Contract
  class Update < Reform::Form

    property :password, virtual: true
    property :password_confirmation, virtual: true

    validates :password, length: { minimum: 8, maximum: 128 }, confirmation: true
  end
end
