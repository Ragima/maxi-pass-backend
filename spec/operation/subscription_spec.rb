# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:user) { create :user, team: team }
  let(:subscription_actions) { create_list :subscription_action, 3 }
  let(:subscription) { create :subscription, subscription_action: subscription_actions.first, user: current_user }

  describe 'Index' do
    subject(:result) { Subscription::Operation::Index.call(current_user: current_user) }

    context 'when admin' do
      let(:current_user) { admin }

      before { subscription }

      it { assert !result[:model].empty? }

      it { assert !result[:serialized_model].empty? }
    end

    context 'when user or lead' do
      let(:current_user) { user }

      it { assert result['result.policy.default'].failure? }
    end
  end

  describe 'Create' do
    subject(:result) { Subscription::Operation::Create.call(current_user: current_user, params: default_params) }

    let(:subscription_action) { create :subscription_action }
    let(:default_params) { { subscription_action_id: subscription_action.id } }

    context 'when user' do
      let(:current_user) { user }

      it { assert result['result.policy.default'].failure? }
    end

    context 'when admin' do
      let(:current_user) { admin }

      it 'subscription action not found' do
        default_params[:subscription_action_id] = 'invalid'
        assert result['result.model'].failure?
      end

      it 'model was found' do
        subscription_action
        default_params[:subscription_action_id] = subscription_action.id
        assert !result['result.model'].failure?
      end

      it 'model was created' do
        assert result.success?
      end

      it { expect { result }.to change(Subscription, :count).by(+1) }
    end
  end

  describe 'destroy' do
    subject(:result) { Subscription::Operation::Destroy.call(params: default_params, current_user: current_user) }

    let(:subscription_action) { create :subscription_action }
    let(:default_params) { { subscription_action_id: subscription_action.id } }

    context 'when user' do
      let(:current_user) { user }

      it { assert result['result.policy.default'].failure? }
    end

    context 'when admin' do
      let(:current_user) { admin }

      before do
        current_user.subscription_actions << subscription_action
      end

      it 'model was found' do
        default_params[:subscription_action_id] = subscription_action.id
        assert !result['result.model'].failure?
      end

      it 'model was deleted' do
        assert result.success?
      end

      it { expect { result }.to change(Subscription, :count).by(-1) }
    end
  end
end
