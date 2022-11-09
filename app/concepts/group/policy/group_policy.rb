# frozen_string_literal: true

module Group::Policy
  class GroupPolicy < ApplicationPolicy
    include Users::Concerns::Role
    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def index?
      user.admin? || user.lead?
    end

    def create?
      user.admin? || user.group_lead?(model.group)
    end

    def show?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model))
    end

    def update?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model))
    end

    def update_parent?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model.parent))
    end

    def delete_parent?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model.parent))
    end

    def update_descendants?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model))
    end

    def destroy?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model))
    end

  end
end
