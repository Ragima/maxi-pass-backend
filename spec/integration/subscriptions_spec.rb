# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Subscription' do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:subscription_actions) { create_list :subscription_action, 2 }
  let(:signed_in_user) { create_user :admin, team: team }
  let(:subscription) { create :subscription, subscription_action: subscription_actions.first, user: signed_in_user }

  path '/api/v1/subscriptions' do
    get 'Shows subscriptions' do
      tags 'Subscription'
      consumes 'application/json'

      response '200', 'subscriptions list' do
        before { subscription_actions }

        run_test!
      end
    end
  end

  path '/api/v1/subscriptions/{id}' do
    delete 'Delete a subscriptions' do
      tags 'Subscription'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true

      response '204', 'subscription deleted' do
        before { subscription }

        let(:id) { subscription_actions.first.id }
        run_test!
      end

      response '404', 'subscription not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/subscriptions/{id}' do
    post 'Create a subscriptions' do
      tags 'Subscription'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true

      response '200', 'subscription created' do

        let(:subscription_action1) { create :subscription_action }
        let(:id) { subscription_action1.id }
        run_test!
      end

      response '404', 'subscription not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
