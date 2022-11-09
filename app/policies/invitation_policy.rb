class InvitationPolicy < ApplicationPolicy
  include Users::Concerns::Role

  def initialize(user, invitation)
    @user = user
    @invitation = invitation
  end

  def index?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def resend_invitation?
    @user.admin? && !@invitation.invitation_token.nil?
  end

  def destroy?
    @user.admin?
  end
end