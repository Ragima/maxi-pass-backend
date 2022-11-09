# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupUser, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'inner_group', parent: group, team: team }
  let(:user) { create_user :user, team: team }

  describe 'Create' do
    subject(:result) { GroupUser::Operation::Create.call(params: default_params, current_user: current_user) }

    let(:default_params) { { group_id: group.id, user_id: user.id } }

    context 'when user' do
      let(:current_user) { create_user :user, team: team }

      it 'expect policy failure' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when user as lead' do
      let(:current_user) { create_user :user, team: team }

      before do
        group2 = create :group, name: 'test', team: team
        GroupUser.create(user: current_user, group: group, role: 'lead')
        GroupUser.create(user: current_user, group: inner_group)
        GroupUser.create(user: current_user, group: group2, role: 'lead')
        GroupUser.create(user: user, group: group2)

      end

      it 'gets success' do
        assert result.success?
      end

      it 'increase group user count' do
        expect { result }.to change(GroupUser, :count).by(2)
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'increase group user count' do
        expect { result }.to change(GroupUser, :count).by(1)
      end
    end
  end

  describe 'Destroy' do
    subject(:result) { GroupUser::Operation::Destroy.call(params: default_params, current_user: current_user) }

    let(:default_params) { { group_id: group.id, user_id: user.id } }

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
        GroupUser.create(user: current_user, group: inner_group)
        GroupUser.create(user: user, group: group)
        GroupUser.create(user: user, group: inner_group)
      end

      it 'gets success' do
        assert result.success?
      end

      it 'reduce group user count' do
        expect { result }.to change(GroupUser, :count).by(-2)
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      before { GroupUser.create(group: group, user: user) }

      it 'gets success' do
        assert result.success?
      end

      it 'reduce group user count' do
        expect { result }.to change(GroupUser, :count).by(-1)
      end
    end
  end

  describe 'Change role' do
    subject(:result) { GroupUser::Operation::ChangeRole.call(params: default_params, current_user: current_user) }

    let(:default_params) { { group_id: group.id, user_id: user.id, role: 'lead' } }

    before { GroupUser.create(user: user, group: group, role: 'user') }

    context 'when user' do
      let(:current_user) { create_user :user, team: team }

      it 'expect policy failure' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      it 'gets success' do
        assert result.success?
      end

      it 'change group user role' do
        assert result[:model].role == 'lead'
      end
    end
  end
end