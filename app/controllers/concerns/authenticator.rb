# frozen_string_literal: true

module Authenticator
  extend ActiveSupport::Concern
  include DeviseTokenAuth::Controllers::Helpers

  included do
    before_action :authenticate_user!
  end

  def authenticate_inviter!
    # use authenticate_user! in before_action
  end

  def authenticate_user!
    render_unauthorized unless user_signed_in?
  end

  def render_unauthorized
    render json: {
      errors: [I18n.t("pundit.unauthorized")]
    }, status: 401
  end
end
