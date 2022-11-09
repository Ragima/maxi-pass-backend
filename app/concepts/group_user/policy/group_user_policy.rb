# frozen_string_literal: true

module GroupUser::Policy
  class GroupUserPolicy < ApplicationPolicy
    include Users::Concerns::Role

    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def update_user_groups?
      model.team_name == user.team_name && !model.role_admin? && (user.admin? || user.user_lead?(model))
    end

    def update_group_users?
      model.team_name == user.team_name && (user.admin? || user.group_lead?(model))
    end

  end
end