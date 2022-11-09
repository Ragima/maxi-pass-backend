module User::Policy
  class UserPolicy < ApplicationPolicy
    include Users::Concerns::Role
    attr_reader :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def index?
      user.admin? || user.lead?
    end

    def invitations?
      user.admin?
    end

    def show?
      model.team_name == user.team_name && !model.role_admin? && (user.admin? || user.user_lead?(model))
    end

    def update?
      show? && model.role_id == 'user'
    end

    def destroy?
      update?
    end

    def change_role?
      return false if user.support?
      model.team_name == user.team_name && user.admin? && !model.admin? && !model.extension_access && !model.blocked
    end

    def users_reset_password?
      user.admin?
    end

    def resend_invitation?
      user.admin?
    end

    def restore?
      user.admin?
    end

    def block?
      user.admin? && !model.admin?
    end

    def unblock?
      user.admin? && !model.admin?
    end
  end
end
