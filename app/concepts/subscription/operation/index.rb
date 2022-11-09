# frozen_string_literal: true

module Subscription::Operation
  class Index < Trailblazer::Operation
    step Policy::Pundit(Subscription::Policy::SubscriptionPolicy, :index?)
    step :model!
    success :serialized_model!

    def model!(options, **)
      options[:model] = SubscriptionAction.all.order(entity_type: :asc, action_type: :asc)
    end

    def serialized_model!(options, model:, current_user:, **)
      options[:serialized_model] = SubscriptionAction::Representer::Index.new(model).to_hash(user_options: { current_user: current_user })
    end
  end
end
