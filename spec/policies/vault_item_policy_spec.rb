# frozen_string_literal: true

require 'rails_helper'

describe 'Vault item policy' do
  subject { VaultItem::Policy::VaultItemPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }

  context 'when user' do
    let(:user) { create :user }
    let(:vault) { create :vault, team: team }
    let(:model) { create :login_item, only_for_admins: true, vault: vault }

    it { is_expected.to forbid_action(:show) }
  end

  context 'when admin' do
    let(:user) { create :admin }
    let(:model) { create :login_item, only_for_admins: true }

    it { is_expected.to permit_actions(%i[show create update destroy copy move]) }
  end

end
