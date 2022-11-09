# frozen_string_literal: true

module Team::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :name
      property :otp_required_for_login
      property :created_at
      property :updated_at
    end
  end
end