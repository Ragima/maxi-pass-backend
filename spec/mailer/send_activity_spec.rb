require 'rails_helper'

RSpec.describe AdminMailer, type: :admin_mailer do
  describe 'instructions' do
    let(:team) { create(:team) }
    let(:user) { create(:admin, team: team) }
    let(:activity) { create(:activity, trackable_id: user.id, team_name: team.id, actor_action: 'Create', actor_email: user.email) }
    let(:mail) { AdminMailer.send(:notification_email, user, activity).deliver_now }

    it 'renders the receiver email, renders the sender email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['maxipass.notifier@maxipass.com'])
    end
  end
end
