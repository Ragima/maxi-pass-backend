# frozen_string_literal: true

class PasswordMailer < ApplicationMailer
  default from: 'password.mailer@bookstime.com'
  layout 'mailer'

  def restore_completed(user)
    @email = user.email
    @team_name = user.team_name
    mail from: 'recovery@maxipass.com'
    mail subject: 'MaxiPass | Reset password instructions'
    mail to: @email
  end
end
