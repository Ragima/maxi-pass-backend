class EnableTwoFactorJob < ApplicationJob
  queue_as :two_factor

  def perform(team_name)
    users = Team.find_by(name: team_name).users
    users.each { |user| user.update(otp_secret: User.generate_otp_secret) }
    users.each do |user|
      TwoFactorAuthMailer.send(:qr_code_email, user).deliver_now
    end
  end
end
