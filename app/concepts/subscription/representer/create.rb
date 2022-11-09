# frozen_string_literal: true

module SubscriptionAction::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :id
      property :entity_type
      property :action_type
    end
  end
end
