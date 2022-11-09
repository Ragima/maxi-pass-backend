class UserPolicy < ApplicationPolicy
  include Users::Concerns::Role

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def generate_report?
    @current_user.team_name == @user.team_name && (@current_user.admin? || @current_user.user_lead?(@user))
  end
end
