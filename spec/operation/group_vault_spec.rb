# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupVault, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create_user :admin, team: team }
  let(:user) { create_user :user, team: team }
  let(:group) { create_group current_user, team: team, name: 'some name' }
  let(:vault) { create_shared_vault current_user, team: team }

  describe 'Create' do
    let(:result) { GroupVault::Operation::Create.call(current_user: current_user, params: default_params) }

    let(:default_params) { { group_id: group.id, vault_id: vault.id } }

    context 'when user' do
      let(:current_user) { user }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { admin }

      it 'gets not found' do
        params = { group_id: 'invalid', vault_id: vault.id }
        result = GroupVault::Operation::Create.call(current_user: current_user, params: params)
        assert result['result.model'].failure?
      end

      it 'gets success' do
        assert result.success?
      end

      it 'increase group vault relation' do
        expect { result }.to change(GroupVault, :count).by(1)
      end
    end
  end

  describe 'Destroy' do
    let(:result) { GroupVault::Operation::Destroy.call(current_user: current_user, params: default_params) }

    let(:default_params) { { group_id: group.id, vault_id: vault.id } }

    context 'when user' do
      let(:current_user) { user }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { admin }

      it 'gets not found' do
        params = { group_id: 'invalid', vault_id: vault.id }
        result = GroupVault::Operation::Destroy.call(current_user: current_user, params: params)
        assert result['result.model'].failure?
      end

      before { GroupVault.create(group: group, vault: vault) }

      it 'gets success' do
        assert result.success?
      end

      it 'increase group vault relation' do
        expect { result }.to change(GroupVault, :count).by(-1)
      end
    end
  end
end