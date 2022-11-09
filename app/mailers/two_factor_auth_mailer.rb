# frozen_string_literal: true

class TwoFactorAuthMailer < ApplicationMailer
  def qr_code_email(user)
    @url = Rails.application.config.action_mailer.default_url_options
    attachments['qr_code'] = {
      data: RQRCode::QRCode.new(user.two_factor_url).as_png(size: 240, file: nil).to_datastream.to_blob,
      mime_type: 'image/png'
    }
    @code = user.otp_secret
    @team_name = user.team_name
    mail(to: user.email, subject: 'MaxiPass your team added two factor auth')
  end
end
