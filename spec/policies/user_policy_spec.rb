require 'rails_helper'

describe 'User policy' do
  subject(:result) { User::Policy::UserPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }
  let(:model) { create :user, team: team }

  context 'when admin' do
    let(:user) { create :admin, team: team }

    it { is_expected.to permit_actions(%i[invitations index show update destroy change_role block unblock]) }
  end

  context 'when support' do
    let(:user) { create :support, team: team }

    it { is_expected.to permit_actions(%i[invitations index show update destroy block unblock]) }
  end

  context 'when user' do
    let(:user) { create :user, team: team }

    it { is_expected.to forbid_actions(%i[invitations index show update destroy change_role block unblock]) }
  end

  context 'when user as lead' do
    let(:user) { create :user, team: team }
    let(:group) { create :group, name: 'test', team: team }
    let(:model) { create :user, team: team }

    before { GroupUser.create(group: group, user: user, role: 'lead') }

    it 'forbid actions if lead of a group' do
      expect(result).to forbid_actions(%i[invitations show update destroy change_role block unblock])
    end

    it 'permit actions if lead of a group' do
      GroupUser.create(user: model, group: group)
      expect(result).to permit_actions(%i[index show update destroy])
    end
  end
end
