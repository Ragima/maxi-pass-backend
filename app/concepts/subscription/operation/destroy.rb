# frozen_string_literal: true

module Subscription::Operation
  class Destroy < Trailblazer::Operation
    step Model(SubscriptionAction, :find_by_subscription_action_id, :subscription_action_id)
    step Policy::Pundit(Subscription::Policy::SubscriptionPolicy, :destroy?)
    success :subscription!
    step :destroy!

    def subscription!(options, current_user:, model:, **)
      options[:subscription] = current_user.subscriptions.find_by(subscription_action: model)
    end

    def destroy!(options, subscription:, **)
      options['model.response'] = :no_content
      return true if subscription.nil?

      subscription.destroy
      result = Result.new(!subscription.persisted?, {})
      result.success?
    end
  end
end
