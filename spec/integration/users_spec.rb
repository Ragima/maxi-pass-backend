# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Users' do
  let(:team) { create(:team) }

  path '/api/v1/invitations' do
    get 'Show invitations' do
      tags 'Users'
      consumes 'application/json'

      let(:signed_in_user) { create(:admin, team: team) }

      response '200', 'show invitations' do
        before { create_list :invited_user, 3, team: team }

        run_test!
      end
    end
  end

  path '/api/v1/users' do
    get 'Shows users' do
      tags 'Users'
      consumes 'application/json'

      let(:signed_in_user) { create(:user, role_id: 'admin', team: team) }
      before do
        users = create_list :user, 2, team: team
        groups = create_list :group, 2, team: team
        users.each do |user|
          groups.each do |group|
            GroupUser.create(user: user, group: group, role: %w[lead user].sample)
          end
        end
      end

      response '200', 'show users' do
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    get 'Shows user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, team: team }
      let(:signed_in_user) { create :admin, team: team }

      before do
        groups = create_list :group, 2, team: team
        vaults = create_list :vault, 2, team: team
        GroupUser.create(user: user, group: groups.first)
        GroupVault.create(group: groups.first, vault: vaults.second)
        UserVault.create(user: user, vault: vaults.first)
      end

      response '200', 'show user' do
        let(:id) { user.id }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    put 'Update user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }, required: %w[name]
      }

      let(:user_to_update) { create :user, team: team }
      let(:signed_in_user) { create :admin, team: team }

      response '200', 'update user' do
        let(:id) { user_to_update.id }
        let(:user) { { name: FFaker::Name.name } }
        run_test!
      end
    end
  end

  path '/api/v1/update_settings' do
    put 'Update settings' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          first_name: { type: :string },
          last_name: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string },
          current_password: { type: :string },
          locale: { type: :string }
        }
      }
      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'User settings updated' do
        let(:user) { { first_name: 'bla', last_name: 'bla', locale: 'ru' } }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    delete 'Destroy user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:signed_in_user) { create :admin, team: team }
      let(:user) { create :user, team: team }

      response '204', 'user destroyed' do
        let(:id) { user.id }
        run_test!
      end
    end
  end

  path '/api/v1/users_reset_password' do
    get 'Users with reset password' do
      tags 'Users'
      consumes 'application/json'

      let(:signed_in_user) { create :admin, team: team }

      response '200', 'Show users with reset password' do
        before { create_list :user, 3, team: team, reset_pass: true }

        run_test!
      end
    end
  end

  path '/api/v1/users/{user_id}/change_role' do
    put 'Update role user to admin' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true

      let(:signed_in_user) { create :admin, team: team }

      response '200', 'User updated to role_id admin' do
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end

      response '403', 'User not permitted' do
        let(:user_id) { create(:admin, team: team).id }
        run_test!
      end

      response '404', 'User not found' do
        let(:user_id) { 'invalid_id' }
        run_test!
      end
    end
  end

  path '/api/v1/users/{user_id}/restore' do
    put 'Restore user access after reset password' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true
      let(:signed_in_user) { create_user :admin, team: team }

      response '200', 'User successfully restores' do
        let(:user_id) { create(:user, team: team, reset_pass: true).id }
        run_test!
      end
      response '404', 'User not found' do
        let(:user_id) { 'invalid_id' }
        run_test!
      end
    end
  end

  path '/api/v1/users/{user_id}/toggle_block' do
    put 'Block or unblock user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user_id, in: :path, required: true
      let(:signed_in_user) { create :admin, team: team }

      response '204', 'User successfully blocked or unblocked' do
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
      response '404', 'User not found' do
        let(:user_id) { 'invalid' }
        run_test!
      end
      response '403', 'User not permitted' do
        let(:signed_in_user) { create :user, team: team }
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}/generate_report' do
    post 'Generate report' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :report_receiver_id, in: :query, type: :string, required: true

      let(:signed_in_user) { create_user :admin, team: team }
      let(:group)          { create :group, name: 'test', team: team }
      let(:user1)           { create :user, team: team }

      response '200', 'report generated' do
        before do
          signed_in_user.groups << group
          user1.groups << group
        end

        let(:id) { signed_in_user.id }
        let(:report_receiver_id) { user1.id }
        run_test!
      end
    end
  end
end
