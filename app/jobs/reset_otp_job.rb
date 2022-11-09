class ResetOtpJob < ApplicationJob
  queue_as :two_factor

  def perform(user_id)
    user = User.find(user_id)
    TwoFactorAuthMailer.send(:qr_code_email, user).deliver_now
  end
end
