# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'UserVaults' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/user_vaults/{user_id}/{vault_id}' do
    post 'Create user vaults relation' do
      tags 'UserVaults'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true
      parameter name: :vault_id, in: :path, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'User added to vault' do
        let(:user_id) { create(:user, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        run_test!
      end
      response '404', 'Vault or user not found' do
        let(:user_id) { 'invalid' }
        let(:vault_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:user_id) { create(:user, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        run_test!
      end
    end
  end

  path '/api/v1/user_vaults/{user_id}/{vault_id}' do
    delete 'Destroy user vaults relation' do
      tags 'UserVaults'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true
      parameter name: :vault_id, in: :path, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '204', 'Destroy user vault relation' do
        let(:user_id) { create(:user, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        before { UserVault.create(user_id: user_id, vault_id: vault_id) }

        run_test!
      end
      response '404', 'Vault or user not found' do
        let(:user_id) { 'invalid' }
        let(:vault_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:user_id) { create(:user, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        run_test!
      end
    end
  end

  path '/api/v1/user_vaults/{user_id}/{vault_id}/change_role' do
    put 'Change user role related to vault' do
      tags 'UserVaults'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true
      parameter name: :vault_id, in: :path, required: true
      parameter name: :vault_writer, in: :body, required: true, schema: {
        type: :object,
        properties: {
          vault_writer: { type: :boolean }
        }
      }

      let(:signed_in_user) { create :admin, team: team }

      response '200', 'User updated to vault_writer: true' do
        let(:user_id) { create(:user, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        let(:vault_writer) { { vault_writer: true } }
        before { UserVault.create(user_id: user_id, vault_id: vault_id) }

        run_test!
      end
      response '404', 'Vault or user not found' do
        let(:user_id) { 'invalid' }
        let(:vault_id) { 'invalid' }
        let(:vault_writer) { { vault_writer: true } }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:user_id) { create(:user, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        let(:vault_writer) { { vault_writer: true } }
        run_test!
      end
    end
  end
end