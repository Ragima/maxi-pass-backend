# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVault, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:group) { create :group, name: 'test', team: team }
  let(:vault) { create_shared_vault current_user, team: team }
  let(:user) { create_user :user, team: team }

  describe 'Create' do
    subject(:result) { UserVault::Operation::Create.call(params: default_params, current_user: current_user) }

    let(:default_params) { { vault_id: vault.id, user_id: user.id } }

    context 'when user' do
      let(:current_user) { create_user :user, team: team }

      it 'expect policy failure' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when user as lead' do
      let(:current_user) { create_user :user, team: team }

      before do
        GroupUser.create(user: current_user, group: group, role: 'lead')
        GroupUser.create(user: user, group: group, role: 'user')
        GroupVault.create(group: group, vault: vault)
      end

      it 'gets success' do
        assert result.success?
      end

      it 'increase group user count' do
        expect { result }.to change(UserVault, :count).by(1)
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'increase group user count' do
        expect { result }.to change(UserVault, :count).by(1)
      end
    end
  end

  describe 'Destroy' do
    subject(:result) { UserVault::Operation::Destroy.call(params: default_params, current_user: current_user) }

    let(:default_params) { { vault_id: vault.id, user_id: user.id } }

    context 'when user' do
      let(:current_user) { create_user :user, team: team }

      it 'expect policy failure' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when user as lead' do
      let(:current_user) { create_user :user, team: team }

      before do
        GroupUser.create(user: current_user, group: group, role: 'lead')
        GroupUser.create(user: user, group: group, role: 'user')
        GroupVault.create(group: group, vault: vault)
        UserVault.create(user: user, vault: vault)
      end

      it 'gets success' do
        assert result.success?
      end

      it 'reduce group user count' do
        expect { result }.to change(UserVault, :count).by(-1)
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      before { UserVault.create(user: user, vault: vault) }

      it 'gets success' do
        assert result.success?
      end

      it 'reduce user vault count' do
        expect { result }.to change(UserVault, :count).by(-1)
      end
    end
  end

  describe 'Change role' do
    subject(:result) { UserVault::Operation::ChangeRole.call(params: default_params, current_user: current_user) }

    let(:default_params) { { vault_id: vault.id, user_id: user.id, vault_writer: true } }

    context 'when user' do
      let(:current_user) { create_user :user, team: team }

      it 'expect policy failure' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      before { UserVault.create(user: user, vault: vault) }

      it 'gets success' do
        assert result.success?
      end

      it 'gets not found' do
        params = { vault_id: 'invalid', user_id: user.id, vault_writer: true }
        result = UserVault::Operation::ChangeRole.call(params: params, current_user: current_user)
        assert result['result.model'].failure?
      end

      it 'change user role to vault writer' do
        assert result[:model].vault_writer
      end
    end
  end
end