# frozen_string_literal: true

module TwoFactorAuth::Operation
  class OtpReset < Trailblazer::Operation
    step Model(User, :find_by, :email)
    step Policy::Pundit(TwoFactorAuth::Policy::TwoFactorAuthPolicy, :reset_otp?)
    success :update_user!
    success :send_email!

    def model!(options, params:, **)
      options[:model] = model = User.find_by(email: params[:email], team_name: params[:team_name])
      options['result.model'] = result = Result.new(!model.nil?, {})
      result.success?
    end

    def update_user!(_options, model:, **)
      model.activate_otp
    end

    def send_email!(options, model:, **)
      ResetOtpJob.perform_later(model.id)
      options['model.response'] = :no_content
    end

  end
end

