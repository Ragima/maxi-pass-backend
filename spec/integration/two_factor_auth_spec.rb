require 'swagger_helper'

RSpec.describe 'Two Factor Auth' do
  let!(:team) { create :team, name: 'team' }

  let(:signed_in_user) { create(:admin, team: team) }
  let(:team_name) { team.name }

  path '/api/v1/enable_two_factor/{team_name}' do
    post 'Two Factor Auth Enable' do
      tags 'Two Factor Auth'
      consumes 'application/json'
      parameter name: :team_name, in: :path, type: :string

      response '200', 'Two Factor Auth Enabled' do
        run_test!
      end
    end
  end

  path '/api/v1/check_two_factor' do
    get 'Two Factor Auth Check for team' do
      tags 'Two Factor Auth'
      consumes 'application/json'
      parameter name: :team_name, in: :body, type: :string

      response '200', 'Two Factor Auth Check For Team' do
        run_test!
      end
    end
  end

  path '/api/v1/enable_two_factor/{team_name}' do
    post 'Two Factor Auth Enable' do
      tags 'Two Factor Auth'
      consumes 'application/json'
      parameter name: :team_name, in: :path, type: :string

      let(:team2) { create :team, name: 'team2', otp_required_for_login: true}
      let(:signed_in_user) { create(:admin, team: team2) }
      let(:team_name) { team2.name }

      response '204', 'Two Factor Auth Enabled for team with enabled auth' do
        run_test!
      end
    end
  end

  path '/api/v1/disable_two_factor/{team_name}' do
    post 'Disable Two Factor Auth' do
      tags 'Two Factor Auth'
      consumes 'application/json'
      parameter name: :team_name, in: :path, type: :string

      response '200', 'Two Factor Auth Disabled' do
        run_test!
      end
    end
  end

end