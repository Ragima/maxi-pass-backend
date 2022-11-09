# frozen_string_literal: true

module InviteMethods
  extend ActiveSupport::Concern

  def current_inviter
    @current_user
  end

  def resource_class(m = nil)
    mapping = if m
                Devise.mappings[m]
              else
                Devise.mappings[resource_name] || Devise.mappings.values.first
              end
    mapping.to
  end

  def resource_from_invitation_token
    @invitation_token = params[:invitation_token] || params[:invitation][:invitation_token]
    @resource = resource_class.find_by_invitation_token(@invitation_token, true)
    return if @invitation_token && @resource

    render json: { errors: [I18n.t('devise.invitations.invitation_token_invalid')] }, status: :not_acceptable
  end
end