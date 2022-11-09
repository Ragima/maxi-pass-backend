# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def notification_email(user, activity)
    @url = Rails.application.config.action_mailer.default_url_options
    @team_name = activity.team_name
    @message = "#{activity.actor_email} #{activity.actor_action}"
    @message += " #{activity.subj1_title}" if activity.subj1_title
    @message += " #{activity.subj1_action}" if activity.subj1_action
    @message += " #{activity.subj2_title}" if activity.subj2_title
    @message += " #{activity.subj2_action}" if activity.subj2_action
    @message += " #{activity.subj3_title}" if activity.subj3_title
    @date = activity.created_at.to_date
    @time = activity.created_at.strftime('%H:%M:%S')
    mail(to: user.email, subject: 'MaxiPass activity notification')
  end
end
