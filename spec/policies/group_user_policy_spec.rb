require 'rails_helper'

describe 'Group User policy' do
  subject(:result) { GroupUser::Policy::GroupUserPolicy.new(user, model) }

  let(:team) { create :team, name: 'team' }

  describe 'model is group' do
    let(:model) { create :group, name: 'test', team: team }

    context 'when user' do
      let(:user) { create :user, team: team }

      it { is_expected.to forbid_actions(%i[update_group_users]) }
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it { is_expected.to permit_actions(%i[update_group_users]) }
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      before { GroupUser.create(group: model, user: user, role: 'lead') }

      it { is_expected.to permit_actions(%i[update_group_users]) }
    end

  end

  describe 'model is user' do
    let(:model) { create :user, team: team }

    context 'when user' do
      let(:user) { create :user, team: team }

      it { is_expected.to forbid_actions(%i[update_user_groups]) }
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it { is_expected.to permit_actions(%i[update_user_groups]) }
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      before do
        group = create :group, name: 'test', team: team
        GroupUser.create(group: group, user: model)
        GroupUser.create(group: group, user: user, role: 'lead')
      end

      it { is_expected.to permit_actions(%i[update_user_groups]) }
    end
  end
end