# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Team two factor auth', type: :request do
  describe 'Get /api/v1/check_two_factor' do

    let(:team_enabled) { create :team, otp_required_for_login: true }
    let(:team_disabled) { create :team, otp_required_for_login: false }

    before do
      get '/api/v1/check_two_factor', params: { team_name: team_name }
    end

    context 'with team two factor auth enabled response true' do
      let(:team_name) { team_enabled.name }

      it { expect(response_body['otp_required_for_login']).to eq(true) }
    end

    context 'with team two factor auth disabled response false' do
      let(:team_name) { team_disabled.name }

      it { expect(response_body['otp_required_for_login']).to eq(false) }

    end

    context 'with invalid team response false' do
      let(:team_name) { 'invalid team name' }

      it { expect(response_body['otp_required_for_login']).to eq(false) }
    end
  end
end
