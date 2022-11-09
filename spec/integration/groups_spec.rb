# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Groups' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/groups' do
    get 'Shows groups' do
      tags 'Groups'
      consumes 'application/json'

      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'groups find' do
        before { create_list :group, 2, team: team }

        run_test!
      end
    end
  end

  path '/api/v1/groups' do
    post 'Creates a group' do
      tags 'Groups'
      consumes 'application/json'
      parameter name: :group, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          parent_group_id: { type: :string }
        },
        required: %w[name]
      }

      let(:group)          { { name: '111' } }
      let(:signed_in_user) { create_user :admin, team: team }

      response '201', 'group created' do
        let(:group) { { name: 'name' } }
        run_test!
      end
    end
  end

  path '/api/v1/groups/{id}' do

    let(:signed_in_user) { create_user :admin, team: team }
    let(:group)          { create :group, name: 'test', team: team }

    get 'Show a group' do
      tags 'Groups'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'Group founded' do

        let(:id) { group.id }
        run_test!
      end

      response '403', 'User not permitted' do
        let(:signed_in_user) { create :user, team: team }
        let(:id) { group.id }
        run_test!
      end

      response '404', 'Group not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/groups/{id}' do

    let(:signed_in_user) { create_user :admin, team: team }
    let(:group)          { create :group, name: 'test', team: team }

    delete 'Delete a group' do
      tags 'Groups'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      response '204', 'group deleted' do

        let(:id) { group.id }
        run_test!
      end

      response '404', 'group not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end


  path '/api/v1/groups/{id}' do
    put 'Update a group' do
      tags 'Groups'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :group, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          parent_group_id: { type: :string }
        },
        required: %w[name]
      }

      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'group updated' do
        let(:id) { create(:group, team: team).id }
        let(:group) { { group: { name: 'ergregwrewg' } } }
        run_test!
      end

      response '404', 'group not found' do
        let(:id) { 'invalid' }
        let(:group) { { group: { name: 'test' } } }
        run_test!
      end
    end
  end

  path '/api/v1/groups/{group_id}/update_parent/{parent_group_id}' do
    put 'Update parent' do
      tags 'Groups'
      consumes 'application/json'
      parameter name: :group_id, in: :path, type: :string, required: true
      parameter name: :parent_group_id, in: :path, type: :string, required: true

      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'group parent updated' do
        let(:group_id) { create(:group, team: team).id }
        let(:parent_group_id) { create(:group, team: team).id }
        run_test!
      end

      response '404', 'group not found' do
        let(:group_id) { 'invalid' }
        let(:parent_group_id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/groups/{id}/generate_report' do
    post 'Generate report' do
      tags 'Groups'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user_id, in: :query, type: :string, required: true

      let(:signed_in_user) { create_user :admin, team: team }
      let(:group)          { create :group, name: 'test', team: team }

      response '200', 'report generated' do
        let(:id) { group.id }
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
    end
  end
end
