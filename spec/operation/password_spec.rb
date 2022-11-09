# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Password, entity_type: :operation do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create_user :admin, team: team }

  describe 'Create' do
    subject(:result) { Password::Operation::Create.call(params: default_params) }

    let(:default_params) { { email: current_user.email, team_name: team.name } }
    let(:current_user) { create_user :admin, team: team }

    it 'gets not found' do
      default_params[:email] = 'invalid'
      assert result['result.model'].failure?
    end

    it 'gets success' do
      assert result.success?
    end
  end

  describe 'Edit' do
    subject(:result) { Password::Operation::Accept.call(params: default_params) }

    let(:team) { create :team, name: 'team' }
    let(:tokens) { Devise.token_generator.generate(User, :reset_password_token) }
    let(:user) { create :user, team: team, reset_password_sent_at: Time.now.utc, reset_password_token: tokens[1], public_key: '1', private_key: '1' }
    let(:default_params) { { reset_password_token: tokens[0] } }

    before do
      user
    end

    it 'gets not found' do
      default_params[:reset_password_token] = 'invalid'
      assert result['result.model'].failure?
    end

    it 'reset password token is expired' do
      user.update_attributes(reset_password_sent_at: Time.now.utc - 7.hours)
      assert result['result.policy.default'].failure?
    end

    it do
      expect(result[:model]).not_to be_nil
      expect(result[:model].public_key).to be_nil
      expect(result[:model].private_key).to be_nil
    end
  end

  describe 'Update' do
    subject(:result) { Password::Operation::Update.call(params: default_params, current_user: current_user) }

    let(:team) { create :team, name: 'team' }
    let(:current_user) { create :user, team: team, change_pass: true }
    let(:default_params) { { password: 'aa123456', password_confirmation: 'aa123456' } }

    it do
      expect(result[:model]).not_to be_nil
      expect(result[:model].public_key).not_to be_nil
      expect(result[:model].private_key).not_to be_nil
      expect(result[:model].change_pass).to be_falsey
    end

    it 'failed if passwords do not match' do
      default_params[:password_confirmation] = 'aa123467'
      assert result['contract.default'].errors.messages.include?(:password_confirmation)
    end
  end
end
