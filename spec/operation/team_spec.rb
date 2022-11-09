# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:user) { create_user :user, team: team }
  let(:admin) { create :admin, team: team }

  describe 'enable two factor auth ' do
    let(:result) { Team::Operation::EnableTwoFactor.call(current_user: current_user, params: default_params) }

    context 'when user' do
      let(:current_user) { user }
      let(:default_params) { { team_name: current_user.team_name } }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { admin }
      let(:default_params) { { team_name: current_user.team_name } }

      it 'gets not found' do
        params = {  team_name: 'team22' }
        result = Team::Operation::EnableTwoFactor.call(current_user: current_user, params: params)
        assert result['result.model'].failure?
      end

      it 'gets success' do
        assert result.success?
      end

      it 'otp auth enabled' do
        expect(result[:model].otp_required_for_login).to be(true)
      end
    end
  end

  describe 'disable two factor auth ' do
    let(:result) { Team::Operation::DisableTwoFactor.call(current_user: current_user, params: default_params) }

    context 'when user' do
      let(:current_user) { user }
      let(:default_params) { { team_name: current_user.team_name } }

      it 'gets forbidden' do
        assert result['result.policy.default'].failure?
      end
    end

    context 'when admin' do
      let(:current_user) { admin }
      let(:default_params) { { team_name: current_user.team_name } }

      it 'gets not found' do
        params = {  team_name: 'team22' }
        result = Team::Operation::EnableTwoFactor.call(current_user: current_user, params: params)
        assert result['result.model'].failure?
      end

      it 'gets success' do
        assert result.success?
      end

      it 'otp auth disabled' do
        expect(result[:model].otp_required_for_login).to be(false)
      end
    end
  end
end