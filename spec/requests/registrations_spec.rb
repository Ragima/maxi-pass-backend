# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'user registrations', type: :request do
  describe 'POST /auth' do
    context 'when all params are correct' do
      before do
        post '/auth',
             params: {
               email: 'test@example.com',
               password: SecureRandom.base64(18) + '$',
               temp: '1'
             }
      end

      it { expect(response).to have_http_status 201 }
      it 'returns correct responce' do
        user = User.find(json['id'])
        expect(json['provider']).to eq('email')
        expect(json['uid']).to eq('_test@example.com')
        expect(json['email']).to eq('test@example.com')
        expect(json['role_id']).to eq('admin')
        expect(json['temp']).to eq('1')
      end
    end
  end
  #   context 'when params missed' do
  #     before do
  #       post '/auth',
  #            params: {
  #              email: 'test@example.com',
  #              password: '111'
  #            }
  #     end
  #
  #     it { expect(response).to have_http_status 422 }
  #     it 'returns correct responce' do
  #       expect(json['status']).to eq('error')
  #     end
  #   end
  #
  #   context 'when email already have been taken' do
  #     let(:user) { create(:unauthorized_user) }
  #     before do
  #       post '/auth',
  #            params: {
  #                email: user.email,
  #                password: user.password
  #            }
  #     end
  #
  #     it { expect(response).to have_http_status 422 }
  #     it 'returns correct responce' do
  #       expect(json['status']).to eq('error')
  #       expect(json['errors']).to eq(['Email has already been taken'])
  #     end
  #   end
  # end
end
