# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'user reset otp', type: :request do
  describe 'POST /auth/reset_otp' do

    let(:team) { create :team, otp_required_for_login: true }
    let(:unauthorized_user) { create :unauthorized_user, team: team }
    let(:params) { { email: unauthorized_user.email, team_name: unauthorized_user.team_name } }

    before do
      post '/auth/reset_otp', params: params
    end

    context 'when all params are correct' do
      it { expect(response).to have_http_status 204 }
    end

    context 'when user with team disabled two factor auth' do
      let(:team) { create :team }

      it { expect(response).to have_http_status 403 }

    end

    context 'when all params are invalid' do
      let(:params) { { email: FFaker::Internet.email } }

      it { expect(response).to have_http_status 404 }
    end
  end
end
