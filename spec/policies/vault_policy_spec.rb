# frozen_string_literal: true

require 'rails_helper'

describe 'Vault policy' do
  subject { Vault::Policy::VaultPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'inner_group', team: team, parent: group }

  context 'with admin role' do

    let(:user) { create :admin, team: team }

    describe 'admin private vault' do
      let(:model) { create :vault, user: user, is_shared: false }

      it { is_expected.to permit_actions(%i[show_vault_items change_vault_items]) }
      it { is_expected.to forbid_actions(%i[show update destroy]) }
    end

    describe 'shared vault' do
      let(:model) { create :vault, team: team, is_shared: true }

      it { is_expected.to permit_actions(%i[show create update destroy change_vault_items]) }
    end
  end

  context 'when user role' do
    let(:user) { create :user, team: team }
    let(:model) { create :vault, team: team, is_shared: true }

    describe 'user private vault' do
      let(:model) { create :vault, user: user, is_shared: false }

      it { is_expected.to permit_actions(%i[change_vault_items]) }
      it { is_expected.to forbid_actions(%i[create update destroy]) }
    end

    describe 'shared vault' do
      it { is_expected.to forbid_actions(%i[show create update destroy change_vault_items]) }
    end

    describe 'user has access through user vault' do
      before do
        UserVault.create(user: user, vault: model)
      end

      it { is_expected.to permit_actions(%i[show_vault_items]) }
      it { is_expected.to forbid_actions(%i[show create update destroy change_vault_items]) }
    end

    describe 'user has access through user vault as vault writer' do
      before do
        UserVault.create(user: user, vault: model, vault_writer: true)
      end

      it { is_expected.to permit_actions(%i[show_vault_items change_vault_items]) }
      it { is_expected.to forbid_actions(%i[show create update destroy]) }
    end

    describe 'user has access through group' do
      before do
        GroupUser.create(user: user, group: group, role: 'user')
        GroupVault.create(group: group, vault: model)
      end

      it { is_expected.to permit_actions(%i[show_vault_items]) }
      it { is_expected.to forbid_actions(%i[show create update destroy change_vault_items]) }
    end

    describe 'user has access to vault through group as lead' do
      before do
        GroupUser.create(user: user, group: group, role: 'lead')
        GroupVault.create(group: group, vault: model)
      end

      it { is_expected.to permit_actions(%i[show create update destroy change_vault_items]) }
    end

    describe 'user has access to vault through inner group as lead' do
      before do
        GroupUser.create(user: user, group: group, role: 'lead')
        GroupVault.create(group: inner_group, vault: model)
      end

      it { is_expected.to permit_actions(%i[show create update destroy change_vault_items]) }
    end
  end
end
