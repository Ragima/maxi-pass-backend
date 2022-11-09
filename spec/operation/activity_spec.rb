# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:admin1) { create :admin, team: team }
  let(:admin2) { create :admin, team: team }
  let(:user) { create :user, team: team }
  let(:activity1) { create :activity, trackable_id: admin2.id, team_name: team.name, actor_email: admin2.email }
  let(:activity2) { create :activity, trackable_id: admin2.id, action_type: 'Team', team_name: team.name, actor_email: admin2.email }
  let(:activity3) { create :activity, trackable_id: admin2.id, team_name: team.name, actor_email: admin2.email }

  describe 'generate_report' do
    subject(:result) { Activity::Operation::GenerateReport.call(default_params) }

    let(:default_params) { { current_user: user } }

    context 'when user' do
      it 'expect policy failure' do
        result = Activity::Operation::GenerateReport.call(current_user: create(:user, team: team))
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:default_params) { { action_type: "User" } }

      before do
        activity1
        activity2
        activity3
      end

      it 'gets success' do
        result = Activity::Operation::GenerateReport.call(params: default_params, current_user: admin1)

        expect(result[:model].to_a).to match_array([activity1, activity3])
        expect(result[:model].to_a).not_to include([activity2])
      end
    end
  end

  describe 'get index' do
    subject(:result) { Activity::Operation::Index.call(default_params) }

    let(:default_params) { { current_user: user } }

    context 'when user' do
      it 'expect policy failure' do
        result = Activity::Operation::Index.call(current_user: create(:user, team: team))
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:default_params) { { action_type: "User" } }

      before do
        activity1
        activity2
        activity3
      end

      it 'gets success' do
        result = Activity::Operation::Index.call(params: default_params, current_user: admin1)

        expect(result[:model].to_a).to match_array([activity1, activity3])
        expect(result[:model].to_a).not_to include([activity2])
      end
    end
  end
end
