# frozen_string_literal: true

module Subscription::Policy
  class SubscriptionPolicy < ApplicationPolicy
    include Users::Concerns::Role
    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def index?
      user.admin?
    end

    def create?
      user.admin?
    end

    def destroy?
      user.admin?
    end
  end
end
