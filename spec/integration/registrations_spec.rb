# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'User registration' do

  path '/auth' do
    post 'Creates a new user' do
      tags 'Registration'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          first_name: { type: :string },
          last_name: { type: :string },
          temp: { type: :string },
          support_personal_vaults: { type: :string }
        },
        required: %w[email password]
      }

      response '201', 'user registered' do
        let(:user) do
          { email: FFaker::Internet.email,
            password: SecureRandom.base64(18) + '$',
            temp: 'team_1',
            first_name: FFaker::Name.first_name,
            last_name: FFaker::Name.last_name,
            support_personal_vaults: true
          }
        end
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { email: 'email', password: '' } }
        run_test!
      end
    end
  end
end
