# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'inner_group', parent: group, team: team }

  describe 'Invitations' do
    subject(:result) { User::Operation::Invitations.call(current_user: user) }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      before { GroupUser.create(user: user, group: group, role: 'lead') }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets success' do
        assert result.success?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }

      it 'gets success' do
        assert result.success?
      end
    end
  end

  describe 'Index' do
    subject(:result) { User::Operation::Index.call(current_user: user) }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }
      let(:inner_group_user) { create :user, team: team }
      let(:foreign_user) { create :user, team: team }

      before do
        GroupUser.create(user: user, group: group, role: 'lead')
        GroupUser.create(user: inner_group_user, group: inner_group)
      end

      it 'lead not gets users outside his hierarchy of groups' do
        expect(result[:model]).not_to include(foreign_user)
      end

      it 'lead gets users from his hierarchy of groups' do
        expect(result[:model]).to include(inner_group_user)
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets success' do
        assert result.success?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }

      it 'gets success' do
        assert result.success?
      end
    end
  end

  describe 'Show' do
    subject(:result) { User::Operation::Show.call(params: default_params, current_user: user) }

    let(:model) { create :user, team: team }
    let(:default_params) { { id: model.id } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }
      let(:default_params) { { id: model.id } }

      before { GroupUser.create(user: user, group: group, role: 'lead') }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
      it 'gets success' do
        GroupUser.create(user: model, group: inner_group)
        assert result.success?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets success' do
        assert result.success?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }

      it 'gets success' do
        assert result.success?
      end
    end
  end

  describe 'Update' do
    subject(:result) { User::Operation::Update.call(params: default_params, current_user: user) }

    let(:model) { create :user, team: team }
    let(:new_name) { 'test name' }
    let(:default_params) { { id: model.id, user: { name: new_name } } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      before { GroupUser.create(user: user, group: group, role: 'lead') }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
      it 'gets success' do
        GroupUser.create(user: model, group: inner_group)
        assert result.success?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'user gets new name' do
        assert result[:model].reload.name == new_name
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'user gets new name' do
        assert result[:model].reload.name == new_name
      end
    end
  end

  describe 'Destroy' do
    subject(:result) { User::Operation::Destroy.call(params: default_params, current_user: user) }

    let(:model) { create :user, team: team }
    let(:new_name) { 'test name' }
    let(:default_params) { { id: model.id } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      before { GroupUser.create(user: user, group: group, role: 'lead') }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
      it 'gets success' do
        GroupUser.create(user: model, group: inner_group)
        assert result.success?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'reduces users count' do
        assert !result[:model].persisted?
      end
    end

    context 'when support' do
      let(:user) { create :support, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'reduces users count' do
        assert !result[:model].persisted?
      end
    end
  end

  describe 'Restore' do
    subject(:result) { User::Operation::Restore.call(current_user: current_user, params: default_params) }

    let(:user) { create_user :user, reset_pass: true, team: team }
    let(:default_params) { { user_id: user.id, team: team } }

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      it { expect(result[:model]).not_to be_nil }

      it 'old private vault deleted' do
        private_vault = Vault.create(is_shared: false, user: user, title: 'Private')
        result
        expect(Vault.find_by(id: private_vault.id)).to be_nil
      end

      it 'expect generated new key for user groups' do
        group = create_group(current_user, team: team)
        group_user = GroupUser.create(user: user, group: group)
        result
        expect(group_user.reload.group_key).not_to be_empty
      end

      it 'expect generated new key for user vaults' do
        vault = create_shared_vault(current_user, team: team)
        user_vault = UserVault.create(user: user, vault: vault)
        result
        expect(user_vault.reload.vault_key).not_to be_empty
      end

      it do
        expect { result }.to change(Vault, :count).by(+1)
        expect(result[:model].change_pass).to be_falsey
        expect(result[:model].reset_password_token).to be_nil
        expect(result[:model].reset_password_sent_at).to be_nil
        expect(result[:model].reset_pass).to be_falsey
      end
    end

    context 'when support' do
      let(:current_user) { create_user :support, team: team }

      it { expect(result[:model]).not_to be_nil }

      it 'old private vault deleted' do
        private_vault = Vault.create(is_shared: false, user: user, title: 'Private')
        result
        expect(Vault.find_by(id: private_vault.id)).to be_nil
      end

      it 'expect generated new key for user groups' do
        group = create_group(current_user, team: team)
        group_user = GroupUser.create(user: user, group: group)
        result
        expect(group_user.reload.group_key).not_to be_empty
      end

      it 'expect generated new key for user vaults' do
        vault = create_shared_vault(current_user, team: team)
        user_vault = UserVault.create(user: user, vault: vault)
        result
        expect(user_vault.reload.vault_key).not_to be_empty
      end

      it do
        expect { result }.to change(Vault, :count).by(+1)
        expect(result[:model].change_pass).to be_falsey
        expect(result[:model].reset_password_token).to be_nil
        expect(result[:model].reset_password_sent_at).to be_nil
        expect(result[:model].reset_pass).to be_falsey
      end
    end


    context 'when admin and user admin' do
      let(:current_user) { create_user :admin, reset_pass: true, team: team }
      let(:user) { create_user :admin, reset_pass: true, team: team }

      it 'expect generated new key for team groups' do
        group = create_group(current_user, team: team)
        result
        expect(GroupAdminKey.find_by(group: group, user: user)&.key).not_to be_nil
      end

      it 'expect generated new key for team vaults' do
        vault = create_shared_vault(current_user, team: team)
        result
        expect(VaultAdminKey.find_by(vault: vault, user: user)&.key).not_to be_nil
      end
    end

    context 'when user or lead' do
      let(:current_user) { create :user, team: team }

      it { assert result['result.policy.default'].failure? }
    end
  end

  describe 'Users reset password' do
    subject(:result) { User::Operation::UsersResetPassword.call(current_user: current_user) }

    context 'when user' do
      let(:current_user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { create :admin, team: team }

      it 'gets success' do
        assert result.success?
      end
    end

    context 'when support' do
      let(:current_user) { create :support, team: team }

      it 'gets success' do
        assert result.success?
      end
    end
  end

  describe 'Change role' do
    subject(:result) { User::Operation::ChangeRole.call(current_user: current_user, params: default_params) }

    let(:model) { create_user :user, team: team }
    let(:default_params) { { user_id: model.id } }

    context 'when user' do
      let(:current_user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'model gets admin role' do
        assert result[:model].reload.admin?
      end

      it 'vaults in current team gets admin key' do
        vault = create_shared_vault current_user, team: team
        result
        assert VaultAdminKey.exists?(vault: vault, user: model)
      end

      it 'groups in current team gets admin key' do
        group = create_group current_user, team: team
        result
        assert GroupAdminKey.exists?(group: group, user: model)
      end
    end

    context 'when support' do
      let(:current_user) { create_user :support, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end
  end

  describe 'ToggleBlock' do
    subject(:result) { User::Operation::ToggleBlock.call(current_user: current_user, params: default_params) }

    let(:model) { create :user, team: team }
    let(:default_params) { { user_id: model.id } }

    context 'when user' do
      let(:current_user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { create :admin, team: team }

      it 'gets not found' do
        default_params[:user_id] = 'invalid'
        assert result['result.model'].failure?
      end

      it { assert result.success? }

      it 'user blocked' do
        assert result[:model].blocked
      end

      it 'user unblocked' do
        model.update_attributes(blocked: true)
        assert !result[:model].blocked
      end
    end

    context 'when support' do
      let(:current_user) { create :support, team: team }

      it 'gets not found' do
        default_params[:user_id] = 'invalid'
        assert result['result.model'].failure?
      end

      it { assert result.success? }

      it 'user blocked' do
        assert result[:model].blocked
      end

      it 'user unblocked' do
        model.update_attributes(blocked: true)
        assert !result[:model].blocked
      end
    end
  end

  describe 'Update Settings' do
    subject(:result) { User::Operation::UpdateSettings.call(params: ActionController::Parameters.new(user: params), current_user: user) }

    let(:user) { create_user :admin, team: team }
    let(:params) { {} }

    context 'with valid values' do
      let(:params) { { 'locale' => 'ru', 'name' => 'Vasya Pupkin', 'first_name' => 'Pavel', 'last_name' => 'Paradise' } }

      it 'updates user settings to given params' do
        expect(result[:model].reload.attributes).to include(params)
      end
    end

    context 'when invalid values' do
      let(:params) { { locale: 'r' * 11, name: 'Vasya Pupkin', first_name: 'Pavel', last_name: 'Paradise' } }

      it 'does not update user settings to given params if they are not valid' do
        assert result.failure?
      end
    end

    context 'when invalid values' do
      let(:new_password) { SecureRandom.base64(18) + '$' }
      let(:params) { { password: new_password, password_confirmation: new_password, current_password: "BSFExfVDuVKdkUorAlNtBm3/"} }

      it 'when valid password' do
        assert result.success?
      end
    end
  end
end
