# frozen_string_literal: true

module SubscriptionAction::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: SubscriptionAction do
      property :id
      property :entity_type
      property :action_type
      property :active_status, getter: ->(represented:, user_options:, **) { user_options[:current_user].subscriptions.exists?(subscription_action: represented) }
    end
  end
end
