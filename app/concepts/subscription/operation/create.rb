# frozen_string_literal: true

module Subscription::Operation
  class Create < Trailblazer::Operation
    step Model(SubscriptionAction, :find_by_subscription_action_id, :subscription_action_id)
    step Policy::Pundit(Subscription::Policy::SubscriptionPolicy, :create?)
    success :create!
    success :serialized_model!

    def create!(_options, current_user:, model:, **)
      current_user.subscriptions.where(subscription_action: model).first_or_create
    end

    def serialized_model!(options, model:, **)
      options[:serialized_model] = SubscriptionAction::Representer::Show.new(model)
    end
  end
end
