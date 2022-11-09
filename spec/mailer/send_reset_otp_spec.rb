require 'rails_helper'

RSpec.describe TwoFactorAuthMailer, type: :admin_mailer do
  describe 'instructions' do
    let(:team) { create :team, otp_required_for_login: true }
    let(:user) { create(:admin, team: team) }
    let(:mail) { TwoFactorAuthMailer.send(:qr_code_email, user).deliver_now }

    it 'renders the receiver email, renders the sender email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['maxipass.notifier@maxipass.com'])
    end
  end
end
