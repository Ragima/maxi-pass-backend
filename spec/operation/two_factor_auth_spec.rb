# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, entity_type: :operation do
  let(:team) { create :team, name: 'team', otp_required_for_login: true }
  let(:user) { create_user :user, team: team }

  describe 'enable two factor auth ' do
    let(:result) { TwoFactorAuth::Operation::OtpReset.call(current_user: current_user, params: default_params) }

    context 'when user' do
      let(:current_user) { user }
      let(:default_params) { { email: current_user.email, team_name: current_user.team_name } }
      let(:current_user_otp) { current_user.otp_secret }

      it 'gets not found user' do
        params = { email: FFaker::Internet.email }
        result = TwoFactorAuth::Operation::OtpReset.call(current_user: current_user, params: params)
        assert result['result.model'].failure?
      end

      it 'gets success' do
        assert result.success?
      end

      it 'otp secret must be changed ' do
        expect(result[:model].otp_secret).to_not be(current_user_otp)
      end

      it 'gets forbidden' do
        current_user.team.update(otp_required_for_login: false)
        assert result['result.policy.default'].failure?
      end
    end
  end

end