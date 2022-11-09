# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'GroupUsers' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/group_users/{group_id}/{user_id}' do
    post 'Create group users relation' do
      tags 'GroupUsers'
      consumes 'application/json'
      parameter name: :group_id, in: :path, required: true
      parameter name: :user_id, in: :path, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'User added to group' do
        let(:group_id) { create(:group, team: team).id }
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
      response '404', 'Group or user not found' do
        let(:group_id) { 'invalid' }
        let(:user_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:group_id) { create(:group, team: team).id }
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
    end
  end

  path '/api/v1/group_users/{group_id}/{user_id}' do
    delete 'Destroy group users relation' do
      tags 'GroupUsers'
      consumes 'application/json'
      parameter name: :group_id, in: :path, required: true
      parameter name: :user_id, in: :path, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '204', 'User deleted from group' do
        let(:group_id) { create(:group, team: team).id }
        let(:user_id) { create(:user, team: team).id }
        before { GroupUser.create(group_id: group_id, user_id: user_id) }

        run_test!
      end
      response '404', 'Group or user not found' do
        let(:group_id) { 'invalid' }
        let(:user_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:group_id) { create(:group, team: team).id }
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
    end
  end

  path '/api/v1/group_users/{group_id}/{user_id}/change_role' do
    put 'Update role user in group' do
      tags 'GroupUsers'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true
      parameter name: :group_id, in: :path, required: true
      parameter name: :role, in: :body, required: true, schema: {
        type: :object,
        properties: {
          role: { type: :string }
        }
      }

      let(:signed_in_user) { create :admin, team: team }

      response '200', 'User updated to role lead' do
        let(:user_id) { create(:user, team: team).id }
        let(:group_id) { create(:group, team: team).id }
        let(:role) { { role: 'lead' } }
        before { GroupUser.create(user_id: user_id, group_id: group_id) }

        run_test!
      end

      response '404', 'Group or user not found' do
        let(:group_id) { 'invalid' }
        let(:user_id) { 'invalid' }
        let(:role) { { role: 'lead' } }
        run_test!
      end
      response '403', 'User not permitted to do this operation' do
        let(:signed_in_user) { create_user :user, team: team }
        let(:group_id) { create(:group, team: team).id }
        let(:user_id) { create(:user, team: team).id }
        let(:role) { { role: 'lead' } }
        run_test!
      end
      response '422', 'Invalid role' do
        let(:signed_in_user) { create_user :admin, team: team }
        let(:group_id) { create(:group, team: team).id }
        let(:user_id) { create(:user, team: team).id }
        let(:role) { { role: 'admin' } }
        before { GroupUser.create(user_id: user_id, group_id: group_id) }

        run_test!
      end
    end
  end
end