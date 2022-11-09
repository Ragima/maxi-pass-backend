# frozen_string_literal: true

class DeviseCustomMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def invitation_instructions(record, token, opts = {})
    attachments['qr_code'] = {
      data: RQRCode::QRCode.new(record.two_factor_url).as_png(size: 240, file: nil).to_datastream.to_blob,
      mime_type: 'image/png'
    }
    super
  end
end