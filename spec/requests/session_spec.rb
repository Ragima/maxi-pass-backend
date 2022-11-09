# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'sessions', type: :request do
  let!(:user) { create(:user) }
  let(:unauthorized_user) { create(:unauthorized_user) }
  let(:invalid_otp) { '000000' }

  describe 'POST #create' do
    context 'with not verified user' do
      before do
        post '/auth/sign_in',
             params: {
               team_name:"stri7ng",
               email: unauthorized_user.email,
               password: unauthorized_user.password,
               otp_attempt: unauthorized_user.current_otp
             }
      end

      it { expect(response).to have_http_status 401 }
    end

    context 'when sign_in' do

      it 'with valid params' do
        post '/auth/sign_in', params: { email: user.email, password: user.password, team_name: user.team_name}, headers: user.create_new_auth_token

        expect(response).to have_http_status 200
        expect(response.has_header?('access-token')).to eq(true)
      end

      it 'with invalid params' do
        post '/auth/sign_in', params: { email: '', password: user.password, team_name: user.team_name }, headers: user.create_new_auth_token

        expect(response).to have_http_status 401
        expect(response.has_header?('access-token')).to eq(false)
      end
    end

    describe 'sign_out' do
      let!(:user) { create(:user) }

      before { delete '/auth/sign_out', headers: user.create_new_auth_token }

      it { expect(response).to have_http_status 200 }
    end

    describe 'sign_in' do

      before do
        user.team.update(otp_required_for_login: true)
      end

      context 'with enabled two factor auth' do

        let(:otp_code) { user.current_otp }

        it 'with valid otp code' do
          post '/auth/sign_in', params: {email: user.email, password: user.password, team_name: user.team_name, otp_attempt: otp_code }, headers: user.create_new_auth_token
          expect(response).to have_http_status 200
          expect(response.has_header?('access-token')).to eq(true)
        end

        it 'with invalid otp code' do
          post '/auth/sign_in', params: {email: user.email, password: user.password, team_name: user.team_name, otp_attempt: invalid_otp }, headers: user.create_new_auth_token
          expect(response).to have_http_status 403
          expect(response.has_header?('access-token')).to eq(false)
        end
      end
    end
  end
end