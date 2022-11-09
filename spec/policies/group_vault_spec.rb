require 'rails_helper'

describe 'Group Vault policy' do
  subject(:result) { GroupVault::Policy::GroupVaultPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }

  describe 'model is group' do
    let(:model) { create :group, name: 'test', team: team }

    context 'when user' do
      let(:user) { create :user, team: team }

      it { is_expected.to forbid_actions(%i[update_group_vaults]) }
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it { is_expected.to permit_actions(%i[update_vault_groups]) }
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      before { GroupUser.create(group: model, user: user, role: 'lead') }

      it { is_expected.to permit_actions(%i[update_group_vaults]) }
    end

  end

  describe 'model is vault' do
    let(:model) { create :vault, team: team }

    context 'when user' do
      let(:user) { create :user, team: team }

      it { is_expected.to forbid_actions(%i[update_vault_groups]) }
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it { is_expected.to permit_actions(%i[update_vault_groups]) }
    end

    context 'when lead' do
      let(:user) { create :admin, team: team }

      before do
        group = create :group, name: 'test', team: team
        GroupVault.create(group: group, vault: model)
        GroupUser.create(group: group, user: user, role: 'lead')
      end

      it { is_expected.to permit_actions(%i[update_vault_groups]) }
    end
  end
end