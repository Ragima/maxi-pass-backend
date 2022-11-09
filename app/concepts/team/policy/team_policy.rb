# frozen_string_literal: true

module Team::Policy
  class TeamPolicy < ApplicationPolicy
    include Users::Concerns::Role
    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def disable_two_factor?
      model.name == user.team_name && user.admin?
    end

    def enable_two_factor?
      model.name == user.team_name && user.admin?
    end

  end
end