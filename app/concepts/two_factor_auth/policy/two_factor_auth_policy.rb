# frozen_string_literal: true

module TwoFactorAuth::Policy
  class TwoFactorAuthPolicy < ApplicationPolicy
    include Users::Concerns::Role
    attr_accessor :user, :model

    def initialize(user, model)
      @user = user
      @model = model
    end

    def reset_otp?
      user.team.otp_required_for_login
    end

  end
end