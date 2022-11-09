# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Passwords' do
  let(:team) { create :team, name: 'team' }

  path '/auth/password' do
    post 'Reset password with email confirmation' do
      tags 'Passwords'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          team_name: { type: :string }
        }, required: %w[email team_name]
      }

      response '204', 'Email was sent' do
        let(:user) { create :user, team: team }
        let(:params) { { email: user.email, team_name: user.team_name } }
        run_test!
      end

      response '404', 'User was not found' do
        let(:params) { { email: 'invalid', team_name: 'invalid' } }
        run_test!
      end
    end

    put 'Update user password' do
      tags 'Passwords'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string },
          password_confirmation: { type: :string }
        }, required: %w[password password_confirmation]
      }

      response '200', 'Password was changed' do
        let(:signed_in_user) { create :user, team: team, change_pass: true }
        let(:params) { { password: 'aa123456', password_confirmation: 'aa123456' } }
        run_test!
      end

      response '401', 'User was not found' do
        let(:params) { {} }
        run_test!
      end
    end
  end
end
