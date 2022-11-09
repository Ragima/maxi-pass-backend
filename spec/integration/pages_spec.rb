# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Pages' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/pages/home' do
    get 'Get vaults, groups, invitations' do
      tags 'Pages'
      consumes 'application/json'
      let(:signed_in_user) { create(:admin, team: team) }

      before do
        create_list :group, 3, team: team
        create_list :invited_user, 3, team: team
        create_list :vault, 3, team: team
      end

      response '200', 'Groups, vaults, invitations' do
        run_test!
      end
    end
  end

end