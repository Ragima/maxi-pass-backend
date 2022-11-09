# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Session' do

  path '/auth/sign_in' do

    post 'Creates a new session' do
      tags 'Session'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          team_name: { type: :string },
          otp_attempt: { type: :string },
          extension_access: { type: :boolean }
        },
        required: %w[email password team_name]
      }

      let(:user_1) { create(:user) }

      response '200', 'session created' do
        let(:user) { { email: user_1.email, password: user_1.password, team_name: user_1.team_name, otp_attempt: user_1.current_otp } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) { { email: 'email', password: 'ssword' } }
        run_test!
      end
    end
  end

  path '/auth/sign_out' do

    delete 'deleting session' do
      tags 'Session'
      consumes 'application/json'
      parameter name: :id

      let(:signed_in_user) { create(:user) }

      response '200', 'session deleted' do
        run_test!
      end
    end
  end
end
