# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Activities' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/activities/generate_report' do
    post 'Generate report' do
      tags 'Activities'
      consumes 'application/json'
      parameter name: :user_id, in: :query, type: :string, required: true
      parameter name: :action_type, in: :query, type: :string, required: false
      parameter name: :from, in: :query, type: :string, required: false
      parameter name: :to, in: :query, type: :string, required: false
      parameter name: :actor, in: :query, type: :string, required: false
      parameter name: :activity_type, in: :query, type: :string, required: false
      parameter name: :per_page, in: :query, type: :string, required: false
      parameter name: :page, in: :query, type: :string, required: false

      let(:signed_in_user) { create_user :admin, team: team }
      let(:admin2) { create :admin, team: team }
      let(:activity1) { create :activity, trackable_id: admin2.id, team_name: team.name }

      response '204', 'report generated' do
        let(:user_id) { admin2.id }
        let(:action_type) { 'User' }
        run_test!
      end

      response '403', 'User not permitted' do
        let(:signed_in_user) { create :user, team: team }
        let(:user_id) { admin2.id }
        let(:action_type) { 'User' }
        run_test!
      end
    end
  end

  path '/api/v1/activities' do
    get 'Show team activities' do
      tags 'Activities'
      consumes 'application/json'
      parameter name: :action_type, in: :query, type: :string, required: false
      parameter name: :from, in: :query, type: :string, required: false
      parameter name: :to, in: :query, type: :string, required: false
      parameter name: :actor, in: :query, type: :string, required: false
      parameter name: :activity_type, in: :query, type: :string, required: false
      parameter name: :per_page, in: :query, type: :string, required: false
      parameter name: :page, in: :query, type: :string, required: false

      let(:signed_in_user) { create_user :admin, team: team }
      let(:admin2) { create :admin, team: team }
      let(:user) { create :user, team: team }

      response '200', 'activities founded' do
        before { create_list :activity, 3, trackable_id: admin2.id, actor_email: admin2.email, team_name: team.name }
        let(:action_type) { 'User' }
        run_test!
      end

      response '403', 'User not permitted' do
        let(:signed_in_user) { create :user, team: team }
        let(:action_type) { 'User' }
        run_test!
      end
    end
  end
end
