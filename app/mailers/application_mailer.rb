# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'maxipass.notifier@bookstime.com'
  layout 'mailer'
end
