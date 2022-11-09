# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'GroupVaults' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/group_vaults/{group_id}/{vault_id}' do
    post 'Create group vaults relation' do
      tags 'GroupVaults'
      consumes 'application/json'
      parameter name: :group_id, in: :path, required: true
      parameter name: :vault_id, in: :path, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'Vault added to group' do
        let(:group_id) { create(:group, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        run_test!
      end
      response '404', 'Group or vault not found' do
        let(:group_id) { 'invalid' }
        let(:vault_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:group_id) { create(:group, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        run_test!
      end
    end
  end

  path '/api/v1/group_vaults/{group_id}/{vault_id}' do
    delete 'Destroy group vaults relation' do
      tags 'GroupVaults'
      consumes 'application/json'
      parameter name: :group_id, in: :path, required: true
      parameter name: :vault_id, in: :path, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '204', 'Vault deleted from group' do
        let(:group_id) { create(:group, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        before { GroupVault.create(group_id: group_id, vault_id: vault_id) }

        run_test!
      end
      response '404', 'Group or vault not found' do
        let(:group_id) { 'invalid' }
        let(:vault_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:group_id) { create(:group, team: team).id }
        let(:vault_id) { create(:vault, team: team, is_shared: true).id }
        run_test!
      end
    end
  end
end