# frozen_string_literal: true

module Api::V1
  class SubscriptionsController < ApplicationController

    def index
      endpoint operation: Subscription::Operation::Index,
               options: { current_user: current_user }
    end

    def create
      endpoint operation: Subscription::Operation::Create,
               options: { current_user: current_user }
    end

    def destroy
      endpoint operation: Subscription::Operation::Destroy,
               options: { current_user: current_user }
    end

  end
end
