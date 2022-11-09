require 'rails_helper'

describe 'User Vault policy' do
  subject(:result) { UserVault::Policy::UserVaultPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }

  describe 'model is user' do
    let(:model) { create :user, team: team }

    context 'when user' do
      let(:user) { create :user, team: team }

      it { is_expected.to forbid_actions(%i[update_user_vaults]) }
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it { is_expected.to permit_actions(%i[update_user_vaults]) }
    end

    context 'when lead' do
      let(:user) { create :admin, team: team }

      before do
        group = create :group, name: 'test', team: team
        GroupUser.create(group: group, user: model)
        GroupUser.create(group: group, user: user, role: 'lead')
      end

      it { is_expected.to permit_actions(%i[update_user_vaults]) }
    end
  end

  describe 'model is vault' do
    let(:model) { create :vault, team: team }

    context 'when user' do
      let(:user) { create :user, team: team }

      it { is_expected.to forbid_actions(%i[update_vault_users]) }
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it { is_expected.to permit_actions(%i[update_vault_users]) }
    end

    context 'when lead' do
      let(:user) { create :admin, team: team }

      before do
        group = create :group, name: 'test', team: team
        GroupVault.create(group: group, vault: model)
        GroupUser.create(group: group, user: user, role: 'lead')
      end

      it { is_expected.to permit_actions(%i[update_vault_users]) }
    end
  end
end