# frozen_string_literal: true

module Users
  class TwoFactorAuthController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[reset_otp]
    skip_before_action :protect_with_master_key!, only: %i[reset_otp]
    before_action :find_user, only: %i[reset_otp]

    def reset_otp
      endpoint operation: TwoFactorAuth::Operation::OtpReset,
               options: { current_user: @user }
    end

    private

    def find_user
      @user = User.find_by(email: params[:email])
      head(:not_found) if @user.nil?
    end
  end
end
