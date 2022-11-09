# frozen_string_literal: true

class ReportingMailer < ApplicationMailer
  def structure_email(email, report_file_location, subject, report_owner_email, filters)
    @url = Rails.application.config.action_mailer.default_url_options

    attachments["information.pdf"] = File.read(report_file_location)
    @subject_name = subject.try(:name) || subject.try(:title)
    @subject_type = subject.class.to_s
    @report_owner_email = report_owner_email
    @filters = filters
    mail(to: email, subject: "#{@subject_type} information")
  end
end
