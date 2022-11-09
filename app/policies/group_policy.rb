class GroupPolicy < ApplicationPolicy
  include Users::Concerns::Role

  def initialize(user, group)
    @user = user
    @group = group
  end

  def generate_report?
    @user.admin? || @user.group_lead?(@group)
  end
end
