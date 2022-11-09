require 'rails_helper'

describe 'Group policy' do
  subject(:result) { Group::Policy::GroupPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }
  let(:model) { create :group, name: 'group', team: team }

  context 'when admin' do
    let(:user) { create :admin, team: team }

    it { is_expected.to permit_actions(%i[index create show update destroy update_parent update_descendants]) }
  end

  context 'when user' do
    let(:user) { create :user, team: team }

    it { is_expected.to forbid_actions(%i[index create show update destroy update_parent update_descendants]) }
  end

  context 'when user as lead' do
    let(:user) { create :user, team: team }
    let(:group) { create :group, name: 'group', team: team }
    let(:model) { create :group, name: 'inner_group', parent: group, team: team }

    it 'permit actions if lead of current group' do
      GroupUser.create(user: user, group: group, role: 'lead')
      expect(result).to permit_actions(%i[index show create update destroy update_descendants])
    end
    it 'forbid action if lead of current group' do
      GroupUser.create(user: user, group: model, role: 'lead')
      expect(result).to forbid_action(:update_parent)
    end
    it 'permit action if lead of parent group' do
      GroupUser.create(user: user, group: group, role: 'lead')
      expect(result).to permit_actions(%i[index show create update destroy update_descendants update_parent])
    end
  end
end
