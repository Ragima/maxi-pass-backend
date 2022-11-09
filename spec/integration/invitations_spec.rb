# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Invitation' do

  path '/auth/invitation/{id}' do
    delete 'Delete invite' do
      tags 'Invitation'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:team)           { create(:team) }
      let(:signed_in_user) { create(:admin, team: team) }
      let(:user1)          { create(:invited_user, role_id: 'user', team: team) }

      before { signed_in_user.team.users << user1 }

      response '204', 'user destroyed' do
        let(:id) { user1.id }
        run_test!
      end
    end
  end

  path '/auth/invitation/resend_invitation/{id}' do
    get 'Resend invitation' do
      tags 'Invitation'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer

      let(:team)           { create(:team) }
      let(:signed_in_user) { create(:admin, team: team) }
      let(:invitation)     { create(:invited_user, role_id: 'user', team: team) }

      before { signed_in_user.team.users << invitation }

      response '200', 'invite sent' do
        let(:id) { invitation.id }
        run_test!
      end
    end
  end

  path '/auth/invitation/' do
    post 'Create invitation' do
      tags 'Invitation'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              team_name: { type: :string },
              extension_access: { type: :boolean }
            },
            required: %w[email]
          }
        }
      }

      let(:team)           { create(:team) }
      let(:signed_in_user) { create(:admin, team: team) }

      response '201', 'invite sent' do
        let(:params) { { user: { email: FFaker::Internet.email, team_name: team.name } } }
        run_test!
      end
    end
  end

  path '/auth/invitation/' do
    put 'Update invitation' do
      tags 'Invitation'
      consumes 'application/json'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          invitation: {
            type: :object,
            properties: {
              password: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string }
            },
            required: %w[password first_name last_name]
          },
          invitation_token: { type: :string }
        }
      }

      let(:team)           { create(:team) }
      let(:signed_in_user) { create(:admin, team: team) }
      let(:invitation)     { User.invite!(email: 'test@email.com', team_name: team.name) }

      response '201', 'invite sent' do
        let(:params) do
          { invitation:
            { password: SecureRandom.base64(18) + '$',
              first_name: invitation.first_name,
              last_name: invitation.last_name,
              invitation_token: invitation.raw_invitation_token } }
        end
        run_test!
      end
    end
  end
end
