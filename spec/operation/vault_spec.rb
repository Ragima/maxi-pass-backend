# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vault, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:support) { create :support, team: team }
  let(:user) { create :user, team: team }
  let(:lead) { create :user, team: team }
  let(:vault) { create :vault, team: team }
  let(:admin_private_vault) { create :private_vault, team: nil, user: admin }
  let(:support_private_vault) { create :private_vault, team: nil, user: support }
  let(:user_private_vault) { create :private_vault, team: nil, user: user }
  let(:lead_private_vault) { create :private_vault, team: nil, user: lead }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'inner_group', parent: group }
  let(:shared_vault) { create :shared_vault, team: team }
  let(:shared_vault2) { create :shared_vault, team: team }
  let(:shared_vault3) { create :shared_vault, team: team }

  describe 'Index vault' do
    context 'with admin signed in' do
      subject(:result) { Vault::Operation::Index.call(current_user: admin) }

      before do
        shared_vault
        UserVault.create(user: admin, vault: admin_private_vault)
        UserVault.create(user: user, vault: user_private_vault)
      end

      it 'admin gets his own private vault' do
        expect(result[:model]).to include(admin_private_vault)
      end
      it 'admin gets team vaults' do
        expect(result[:model]).to include(shared_vault)
      end
      it "admin doesn't get user private vault" do
        expect(result[:model]).not_to include(user_private_vault)
      end
      it 'private vault first in queue' do
        expect(result[:model].first).to eq(admin_private_vault)
      end
    end

    context 'with support signed in' do
      subject(:result) { Vault::Operation::Index.call(current_user: support) }

      before do
        shared_vault
        UserVault.create(user: support, vault: support_private_vault)
        UserVault.create(user: user, vault: user_private_vault)
      end

      it 'support gets his own private vault' do
        expect(result[:model]).to include(support_private_vault)
      end
      it 'support gets team vaults' do
        expect(result[:model]).to include(shared_vault)
      end
      it "support doesn't get user private vault" do
        expect(result[:model]).not_to include(user_private_vault)
      end
      it 'support vault first in queue' do
        expect(result[:model].first).to eq(support_private_vault)
      end
    end

    context 'with lead signed in' do
      subject(:result) { Vault::Operation::Index.call(current_user: lead) }

      let(:another_group) { create :group, name: 'test', team: team }
      let(:another_vault) { create :vault, team: team }

      before do
        inner_group
        lead_private_vault
        UserVault.create(user: lead, vault: lead_private_vault)
        UserVault.create(user: lead, vault: shared_vault)
        GroupUser.create(group: group, user: lead)
        GroupVault.create(group: group, vault: shared_vault2)
      end

      it 'gets his own private vault' do
        expect(result[:model]).to include(lead_private_vault)
      end
      it 'private vault first in queue' do
        expect(result[:model].first).to eq(lead_private_vault)
      end
      it 'gets vaults shared directly' do
        expect(result[:model]).to include(shared_vault)
      end
      it 'gets vault from group if user in this group' do
        expect(result[:model]).to include(shared_vault2)
      end
    end

    context 'with user signed in' do
      subject(:result) { Vault::Operation::Index.call(current_user: user) }

      before do
        UserVault.create(user: user, vault: user_private_vault)
        UserVault.create(user: user, vault: shared_vault)
        GroupUser.create(group: group, user: user)
        GroupVault.create(group: group, vault: shared_vault2)
      end

      it 'gets his own private vault' do
        expect(result[:model]).to include(user_private_vault)
      end
      it 'gets vaults shared directly' do
        expect(result[:model]).to include(shared_vault)
      end
      it 'gets vaults from groups' do
        expect(result[:model]).to include(shared_vault2)
      end
    end
  end

  describe 'Show vault' do
    subject(:result) { Vault::Operation::Show.call(params: params, current_user: admin) }

    let(:team) { create :team, name: 'team' }
    let(:default_options) { { current_user: admin } }
    let(:vault) { create :vault, team: team }

    it 'vault does not exist' do
      params = { id: 'invalid' }
      result = Vault::Operation::Show.call({ params: params }.merge(default_options))
      assert result['result.model'].failure?
    end

    it 'gets success' do
      params = { id: vault.to_param }
      result = Vault::Operation::Show.call({ params: params }.merge(default_options))
      expect(result[:serialized_model]).not_to be_empty
    end

    it 'gets forbidden' do
      params = { id: create(:vault, team: create(:team)) }
      result = Vault::Operation::Show.call({ params: params }.merge(default_options))
      assert result['result.policy.default'].failure?
    end
  end

  describe 'Create vault' do
    subject(:result) { Vault::Operation::Create.call(params: default_params, current_user: user) }

    let(:team) { create :team, name: 'team' }
    let(:default_params) { { vault: { title: 1, description: 1 } } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:user) { create_user :admin, team: team }

      it 'vault with empty title' do
        params = { vault: { title: '', description: '132' } }
        result = Vault::Operation::Create.call(params: params, current_user: user)
        assert !result['contract.default'].errors.full_messages.empty?
      end
      it 'vault with empty description' do
        params = { vault: { title: 'a', description: '' } }
        result = Vault::Operation::Create.call(params: params, current_user: user)
        assert result.success?
      end
      it 'vault keys generate vault key for current user' do
        assert VaultAdminKey.exists?(vault: result[:model], user: user)
      end

      it 'vault keys generate for current user' do
        second_admin = create_user :admin, team: team
        assert VaultAdminKey.exists?(vault: result[:model], user: second_admin)
      end
    end

    context 'when support' do
      let(:user) { create_user :support, team: team }

      it 'vault with empty title' do
        params = { vault: { title: '', description: '132' } }
        result = Vault::Operation::Create.call(params: params, current_user: user)
        assert !result['contract.default'].errors.full_messages.empty?
      end
      it 'vault with empty description' do
        params = { vault: { title: 'a', description: '' } }
        result = Vault::Operation::Create.call(params: params, current_user: user)
        assert result.success?
      end
      it 'vault keys generate vault key for current user' do
        assert VaultAdminKey.exists?(vault: result[:model], user: user)
      end

      it 'vault keys generate for current user' do
        second_admin = create_user :admin, team: team
        assert VaultAdminKey.exists?(vault: result[:model], user: second_admin)
      end
    end

    context 'when lead' do
      let(:user) { create_user :user, team: team }

      before do
        GroupUser.create(group: create(:group), user: user, role: 'lead')
      end

      it 'creates user vault with lead as writer' do
        assert UserVault.find_by(user: user, vault: result[:model]).vault_writer
      end

      it 'creates user vault with vault key' do
        assert !UserVault.find_by(user: user, vault: result[:model]).vault_key.nil?
      end
    end

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'user not permitted create vaults' do
        assert result['result.policy.default'].failure?
      end
    end
  end

  describe 'Vault update' do
    subject(:result) { Vault::Operation::Update.call(params: default_params, current_user: user) }

    let(:team) { create :team, name: 'team' }
    let(:default_params) { { id: vault.to_param, vault: { title: 1, description: 1 } } }

    context 'when user' do
      let(:user) { create :user, team: team }
      let(:vault) { create :vault, team: team }

      it 'user not permitted update vaults' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }
      let(:vault) { create :vault, team: team, is_shared: true }

      it 'admin not permitted update personal vaults' do
        vault = create :vault, user: user, is_shared: false
        params = { id: vault.to_param, vault: { title: 1, description: 1 } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert result['result.policy.default'].failure?
      end
      it 'vault not found' do
        params = { id: 'invalid', vault: { title: 1, description: 1 } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end
      it 'vault with empty title' do
        params = { id: vault.to_param, vault: { title: '', description: '132' } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert !result['contract.default'].errors.full_messages.empty?
      end
      it 'vault with empty description' do
        params = { id: vault.to_param, vault: { title: '123', description: '' } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert result.success?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }
      let(:vault) { create :vault, team: team, is_shared: true }

      it 'support not permitted update personal vaults' do
        vault = create :vault, user: user, is_shared: false
        params = { id: vault.to_param, vault: { title: 1, description: 1 } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert result['result.policy.default'].failure?
      end
      it 'vault not found' do
        params = { id: 'invalid', vault: { title: 1, description: 1 } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end
      it 'vault with empty title' do
        params = { id: vault.to_param, vault: { title: '', description: '132' } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert !result['contract.default'].errors.full_messages.empty?
      end
      it 'vault with empty description' do
        params = { id: vault.to_param, vault: { title: '123', description: '' } }
        result = Vault::Operation::Update.call(params: params, current_user: user)
        assert result.success?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }
      let(:vault) { create :vault, team: team, is_shared: true }

      before do
        GroupUser.create(user: user, group: group, role: 'lead')
        inner_group.vaults.push(vault)
      end

      it 'gets success if lead of parent group' do
        assert result.success?
      end
    end
  end

  describe 'Vault destroy' do
    subject(:result) { Vault::Operation::Destroy.call(params: default_params, current_user: user) }

    let(:team) { create :team, name: 'team' }
    let(:default_params) { { id: vault.to_param } }

    context 'when user' do
      let(:user) { create :user, team: team }
      let(:vault) { create :vault, team: team }

      it 'user not permitted destroy vaults' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }
      let(:vault) { create :vault, team: team, is_shared: true }

      it 'admin not permitted update personal vaults' do
        vault = create :vault, user: user, is_shared: false
        params = { id: vault.to_param }
        result = Vault::Operation::Destroy.call(params: params, current_user: user)
        assert result['result.policy.default'].failure?
      end
      it 'vault not found' do
        params = { id: 'invalid' }
        result = Vault::Operation::Destroy.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end
      it 'result success' do
        assert result.success?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }
      let(:vault) { create :vault, team: team, is_shared: true }

      it 'support not permitted update personal vaults' do
        vault = create :vault, user: user, is_shared: false
        params = { id: vault.to_param }
        result = Vault::Operation::Destroy.call(params: params, current_user: user)
        assert result['result.policy.default'].failure?
      end
      it 'vault not found' do
        params = { id: 'invalid' }
        result = Vault::Operation::Destroy.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end
      it 'support can not delete vaults' do
        assert result['result.policy.default'].failure?
      end
    end
  end

  describe 'Vault show vault items' do
    subject(:result) { Vault::Operation::VaultItems.call(params: default_params, current_user: user) }

    let(:team) { create :team, name: 'team' }
    let(:vault) { create :vault, team: team, is_shared: true }
    let(:default_params) { { vault_id: vault.to_param } }

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'vault not found' do
        params = { vault_id: 'invalid' }
        result = Vault::Operation::VaultItems.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end
      it 'gets success' do
        assert result.success?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }

      it 'vault not found' do
        params = { vault_id: 'invalid' }
        result = Vault::Operation::VaultItems.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end
      it 'support can not see any items in vaults' do
        assert result.failure?
      end
    end

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end
  end

end
