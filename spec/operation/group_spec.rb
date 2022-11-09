# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:user) { create :user, team: team }
  let(:lead) { create :user, team: team }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'group1', parent: group, team: team }
  let(:inner_group2) { create :group, name: 'group2', parent: inner_group, team: team }
  let(:group2) { create :group, name: 'group3', team: team }
  let(:foreign_group) { create :group, name: 'group4', team: create(:team) }

  describe 'Index' do
    subject(:result) { Group::Operation::Index.call(default_params) }

    let(:default_params) { { current_user: admin } }

    context 'when admin' do
      before do
        group
        inner_group
        foreign_group
      end

      it "doesn't get group from foreign team" do
        expect(result[:model]).not_to include(foreign_group)
      end

      it 'gets all groups from his team' do
        expect(result[:model].to_a).to match_array([group, inner_group])
      end
    end

    context 'when user' do
      it 'expect policy failure' do
        result = Group::Operation::Index.call(current_user: create(:user, team: team))
        assert result['result.policy.default'].failure?
      end
    end

    context 'when user as lead' do
      let(:default_params) { { current_user: lead } }

      before do
        group
        inner_group
        inner_group2
        group2
        GroupUser.create(group: group, user: lead, role: 'lead')
      end

      it 'gets group where hi is lead and all inner groups' do
        expect(result[:model].to_a).to match_array([group, inner_group, inner_group2])
      end

      it "doesn't get groups where hi is not lead" do
        expect(result[:model].to_a).not_to include(group2)
      end
    end
  end

  describe 'Create group' do
    subject(:result) { Group::Operation::Create.call(params: default_params, current_user: user) }

    let(:default_params) { { group: { name: 'group6' } } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:user) { create_user :user, team: team }

      before do
        GroupUser.create(user: user, group: group, role: 'lead')
        user.team.users << admin
        subscription = SubscriptionAction.create(entity_type: 'Group', action_type: 'create')
        admin.subscription_actions << subscription
      end

      it 'gets forbidden if parent_group_id blank' do
        assert result['result.policy.default'].failure?
      end

      it 'gets success' do
        user.team.users << admin
        params = { group: { name: 'group8', parent_group_id: group.to_param } }
        result = Group::Operation::Create.call(params: params, current_user: user, admin: admin)
        assert result.success?
      end
    end

    context 'when admin' do
      let(:user) { create_user :admin, team: team }

      it 'name is not valid' do
        params = { group: { name: '' } }
        result = Group::Operation::Create.call(params: params, current_user: user)
        assert !result['contract.default'].errors.full_messages.empty?
      end

      it 'group keep keys of current admin' do
        create_user :admin, team: team
        assert GroupAdminKey.exists?(group: result[:model], user: user)
      end

      it 'group keep keys of all admins in current team' do
        admin = create_user :admin, team: team
        assert GroupAdminKey.exists?(group: result[:model], user: admin)
      end

      it 'all users from parent group get access to group' do
        temp_result = Group::Operation::Create.call(params: default_params, current_user: user)
        user_from_parent_group = create_user(:user, team: team)
        temp_result[:model].users.push(user_from_parent_group)
        result = Group::Operation::Create.call(params: { group: { name: '123', parent_group_id: temp_result[:model].id } }, current_user: user)
        assert GroupUser.exists?(user: user_from_parent_group, group: result[:model])
      end

      it 'gets success' do
        assert result.success?
      end
    end
  end

  describe 'Show group' do
    subject(:result) { Group::Operation::Show.call(params: default_params, current_user: current_user) }

    let(:default_params) { { id: group.id } }

    context 'when user' do
      let(:current_user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead' do
      let(:current_user) { create_user :user, team: team }

      before do
        GroupUser.create(user: user, group: group, role: 'lead')
      end

      it 'gets forbidden if parent_group_id blank' do
        assert result['result.policy.default'].failure?
      end

      it 'gets success' do
        params = { group: { name: 'test', parent_group_id: group.to_param } }
        result = Group::Operation::Create.call(params: params, current_user: user)
        assert result.success?
      end
    end

    context 'when admin' do
      let(:current_user) { create_user :admin, team: team }

      it 'gets success' do
        assert result.success?
      end
    end
  end

  describe 'Update group' do
    subject(:result) { Group::Operation::Update.call(params: default_params, current_user: user) }

    let(:default_params) { { id: group.id, group: { name: 'test' } } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets not found' do
        params = { id: 'invalid' }
        result = Group::Operation::Update.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end

      it 'name is not valid' do
        params = { id: group.id, group: { name: '' } }
        result = Group::Operation::Update.call(params: params, current_user: user)
        assert !result['contract.default'].errors.full_messages.empty?
      end

      it 'gets success' do
        assert result.success?
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      it 'gets forbidden if not lead of current group' do
        GroupUser.create(user: user, group: inner_group, role: 'lead')
        assert result['result.policy.default'].failure?
      end

      it 'gets success' do
        GroupUser.create(user: user, group: group, role: 'lead')
        assert result.success?
      end
    end
  end

  describe 'Destroy group' do
    subject(:result) { Group::Operation::Destroy.call(params: default_params, current_user: user) }

    let(:default_params) { { id: group.id } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:user) { create :admin, team: team }

      it 'gets not found' do
        params = { id: 'invalid' }
        result = Group::Operation::Destroy.call(params: params, current_user: user)
        assert result['result.model'].failure?
      end

      it 'gets success' do
        assert result.success?
      end

      it 'inner groups also destroyed' do
        inner_group
        expect do
          result
        end.to change(Group, :count).by(-2)
      end
    end

    context 'when lead' do
      let(:user) { create :user, team: team }

      it 'gets forbidden if not lead of current group' do
        GroupUser.create(user: user, group: inner_group, role: 'lead')
        assert result['result.policy.default'].failure?
      end

      it 'gets success' do
        GroupUser.create(user: user, group: group, role: 'lead')
        assert result.success?
      end
    end
  end

  describe 'Update parent group' do
    subject(:result) { Group::Operation::UpdateParent.call(params: default_params, current_user: user) }

    let(:model) { inner_group }
    let(:default_params) { { group_id: model.id, parent_group_id: group2 } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead failure' do
      let(:user) { create :user, team: team }

      it 'gets forbidden when not lead of parent group' do
        GroupUser.create(group: model, user: user, role: 'lead')
        assert result['result.policy.default'].failure?
      end

      it 'gets forbidden when not lead of descendants group' do
        GroupUser.create(group: group, user: user, role: 'lead')
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead success' do
      let(:user_from_parent_group) { create_user(:user, team: team) }
      let(:parent_group2) { create :group, name: 'test', team: team }
      let(:model) { Group::Operation::Create.call(params: { group: { name: '1_2', parent_group_id: parent_group2.id } }, current_user: user)[:model] }
      let(:inner_group) { Group::Operation::Create.call(params: { group: { name: '1_3', parent_group_id: model.id } }, current_user: user)[:model] }
      let(:user) { create_user :user, team: team }

      before do
        GroupUser.create(group: group2, user: user_from_parent_group)
        GroupUser.create(group: group2, user: user, role: 'lead')
        GroupUser.create(group: parent_group2, user: user, role: 'lead')
        model
        inner_group
      end

      it 'gets success' do
        assert result.success?
      end

      it 'expect user of parent group gets access to inner group' do
        result
        assert GroupUser.exists?(group: [model, inner_group], user: user_from_parent_group)
      end
    end
  end

  describe 'delete parent group' do
    subject(:result) { Group::Operation::DeleteParent.call(params: default_params, current_user: user) }

    let(:model) { inner_group }
    let(:default_params) { { group_id: inner_group.id, parent_group_id: group.id } }

    context 'when user' do
      let(:user) { create :user, team: team }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when lead failure' do
      let(:user) { create :user, team: team }

      it 'gets forbidden when not lead of parent group' do
        GroupUser.create(group: model, user: user, role: 'lead')
        assert result['result.policy.default'].failure?
      end
    end
    describe 'success lead' do

      context 'when lead success' do

        subject(:result) { Group::Operation::DeleteParent.call(params: default_params, current_user: admin) }

        let(:default_params) { { group_id: inner_group.id, parent_group_id: model.id } }
        let(:user_from_parent_group) { create_user(:admin, team: team) }
        let(:parent_group2) { create :group, name: 'test', team: team }
        let!(:outer_group) { Group::Operation::Create.call(params: { group: { name: '1_122' } }, current_user: admin)[:model] }
        let!(:model) { Group::Operation::Create.call(params: { group: { name: '1_2', parent_group_id: outer_group.id } }, current_user: admin)[:model] }
        let!(:inner_group) { Group::Operation::Create.call(params: { group: { name: '1_3', parent_group_id: model.id } }, current_user: admin)[:model] }
        let!(:inner_group_2) { Group::Operation::Create.call(params: { group: { name: '1_4', parent_group_id: inner_group.id } }, current_user: admin)[:model] }
        let!(:user) { create_user :user, team: team }

        before(:each) do
          GroupUser.create(group: inner_group_2, user: user, role: 'user')
          GroupUser.create(group: inner_group, user: user, role: 'user')
          GroupUser.create(group: model, user: user, role: 'user')
          GroupUser.create(group: model, user: lead, role: 'lead')
          GroupUser.create(group: outer_group, user: user, role: 'user')
          result
        end

        it 'remove user in ancestors group ' do
          assert GroupUser.where(group: outer_group, user: user).first.nil?
        end

        it 'remove user in parent group' do
          assert GroupUser.where(group: model, user: user).first.nil?
        end

        it 'gets success' do
          assert result.success?
        end

        it 'not remove user if user lead' do
          assert GroupUser.where(group: model, user: lead).first.present?
        end

        it 'user should be in child group' do
          assert GroupUser.where(group: inner_group, user: user).first.present?
        end
      end
    end
  end
end
