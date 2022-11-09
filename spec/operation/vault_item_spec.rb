# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VaultItem, entity_type: :operation do
  let(:team) { create(:team, name: FFaker::Name.unique.name) }
  let(:admin) { create_user(:admin, team: team) }
  let(:support) { create_user(:support, team: team) }
  let(:user) { create_user(:user, team: team) }
  let(:shared_vault) { create_shared_vault(admin) }
  let(:private_vault) { create_private_vault(user) }
  let(:default_options) { { current_user: admin, vault: shared_vault } }
  let(:support_options) { { current_user: support, vault: shared_vault } }
  let(:user_options) { { current_user: user, vault: shared_vault } }

  describe 'Show vault item' do
    %w[login_item credit_card_item server_item].each do |item|
      it 'vault item does not exist' do
        params = { id: 'invalid' }
        result = item.camelize.constantize::Operation::Show.call({ params: params }.merge(default_options))
        assert result['result.model'].failure?
      end

      it 'gets success' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, {})
        params = { id: vault_item.to_param }
        result = item.camelize.constantize::Operation::Show.call({ params: params }.merge(default_options))
        expect(result[:serialized_model]).not_to be_empty
      end

      it 'creates activity' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, {})
        params = { id: vault_item.to_param }
        expect do
          item.camelize.constantize::Operation::Show.call({ params: params }.merge(default_options))
        end.to change(Activity, :count).by(+1)
      end

      it 'support can not see vault items' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, {})
        params = { id: vault_item.to_param }
        result = item.camelize.constantize::Operation::Show.call({ params: params }.merge(support_options))
        assert result['result.policy.default'].failure?
      end
    end
  end

  describe 'Create vault item' do
    %w[login_item credit_card_item server_item].each do |item|
      subject(:result) { item.camelize.constantize::Operation::Create.call({ params: default_params }.merge(default_options)) }

      let(:default_params) { Hash[item.to_sym, { title: 'test', tags: 'test test', some_field: 'some value' }] }
      it "user cant't create login item only for admins" do
        params = Hash[item.to_sym, { only_for_admins: true }]
        assert_policy_fail item.camelize.constantize::Operation::Create, ctx({ params: params }.merge(user_options))
      end

      it 'vault item is invalid' do
        params = Hash[item.to_sym, { title: '' }]
        result = item.camelize.constantize::Operation::Create.call({ params: params }.merge(default_options))
        assert result.failure?
      end

      it 'vault item is valid' do
        assert result.success?
      end

      it 'writes activity' do
        expect { result }.to change(Activity, :count).by(+1)
      end
    end

    context 'when support' do
      %w[login_item credit_card_item server_item].each do |item|
        subject(:result) { item.camelize.constantize::Operation::Create.call({ params: default_params }.merge(default_options)) }

        let(:default_options) { { current_user: support, vault: shared_vault } }

        it "support cant't create login item only for admins" do
          params = Hash[item.to_sym, { only_for_admins: true }]
          assert_policy_fail item.camelize.constantize::Operation::Create, ctx({ params: params }.merge(support_options))
        end
      end
    end
  end

  describe 'Update vault item' do
    %w[login_item credit_card_item server_item].each do |item|
      it "user cant't update login item only for admins" do
        vault_item = create_vault_item(item.to_sym, user, shared_vault, user_name: 'password')
        params = Hash[item.to_sym, { only_for_admins: true }].merge(id: vault_item.id)
        result = item.camelize.constantize::Operation::Update.call({ params: params }.merge(user_options))
        assert result['result.policy.default'].failure?
      end

      it "support cant't update login item only for admins" do
        vault_item = create_vault_item(item.to_sym, support, shared_vault, user_name: 'password')
        params = Hash[item.to_sym, { only_for_admins: true }].merge(id: vault_item.id)
        result = item.camelize.constantize::Operation::Update.call({ params: params }.merge(support_options))
        assert result['result.policy.default'].failure?
      end

      it 'vault item does not exist' do
        params = Hash[item.to_sym, {}].merge(id: 'invalid')
        result = item.camelize.constantize::Operation::Update.call({ params: params }.merge(default_options))
        assert result['result.model'].failure?
      end

      it 'vault item is invalid' do
        vault_item = create_vault_item(item.to_sym, user, shared_vault, user_name: 'password')
        params = Hash[item.to_sym, { title: '' }].merge(id: vault_item.id)
        result = item.camelize.constantize::Operation::Update.call({ params: params }.merge(default_options))
        assert result.failure?
      end

      it 'vault item is valid' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, user_name: 'password')
        params = Hash[item.to_sym, { title: 'some title', username: 'username', password: 'password' }].merge(id: vault_item.id)
        result = item.camelize.constantize::Operation::Update.call({ params: params }.merge(default_options))
        assert result.success?
      end

      it 'creates activity' do
        vault_item = create_vault_item(item.to_sym, user, shared_vault, user_name: 'password')
        params = Hash[item.to_sym, { only_for_admins: true }].merge(id: vault_item.id)
        expect do
          item.camelize.constantize::Operation::Update.call({ params: params }.merge(default_options))
        end.to change(Activity, :count).by(+1)
      end
    end
  end

  describe 'Destroy vault item' do
    %w[login_item credit_card_item server_item].each do |item|
      it 'vault item does not exist' do
        params = { id: 'invalid_id' }
        result = item.camelize.constantize::Operation::Destroy.call({ params: params }.merge(default_options))
        assert result['result.model'].failure?
      end

      it 'gets success' do
        params = { id: create(item.to_sym, vault: shared_vault).to_param }
        result = item.camelize.constantize::Operation::Destroy.call({ params: params }.merge(default_options))
        assert result.success?
      end

      it 'creates activity' do
        params = { id: create(item.to_sym, vault: shared_vault).to_param }
        expect do
          item.camelize.constantize::Operation::Destroy.call({ params: params }.merge(default_options))
        end.to change(Activity, :count).by(+1)
      end

      it 'support can not delete vault item' do
        params = { id: create(item.to_sym, vault: shared_vault).to_param }
        result = item.camelize.constantize::Operation::Destroy.call({ params: params }.merge(support_options))
        assert result['result.policy.default'].failure?
      end
    end
  end

  describe 'Copy vault item' do
    let(:target_vault) { create_shared_vault(admin) }
    let(:copy_item_options) { { current_user: admin, vault: shared_vault, target_vault: target_vault } }

    %w[login_item credit_card_item server_item].each do |item|
      it 'vault_item does not exist' do
        params = Hash["#{item}_id".to_sym, 'invalid_id']
        result = item.camelize.constantize::Operation::Copy.call({ params: params }.merge(copy_item_options))
        assert result['result.model'].failure?
      end

      it 'gets forbidden' do
        params = Hash["#{item}_id".to_sym, create(item.to_sym, vault: shared_vault, only_for_admins: true).to_param]
        user_options = { current_user: user, vault: shared_vault, target_vault: target_vault }
        result = item.camelize.constantize::Operation::Copy.call({ params: params }.merge(user_options))
        assert result['result.policy.default'].failure?
      end

      it 'gets forbidden for support' do
        params = Hash["#{item}_id".to_sym, create(item.to_sym, vault: shared_vault, only_for_admins: true).to_param]
        support_options = { current_user: support, vault: shared_vault, target_vault: target_vault }
        result = item.camelize.constantize::Operation::Copy.call({ params: params }.merge(support_options))
        assert result['result.policy.default'].failure?
      end

      it 'gets success' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, user_name: 'password')
        params = Hash["#{item}_id".to_sym, vault_item.to_param]
        result = item.camelize.constantize::Operation::Copy.call({ params: params }.merge(copy_item_options))
        assert result['result.model'].success?
      end

      it 'creates activity' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, user_name: 'password')
        params = Hash["#{item}_id".to_sym, vault_item.to_param]
        expect do
          item.camelize.constantize::Operation::Copy.call({ params: params }.merge(copy_item_options))
        end.to change(Activity, :count).by(+1)
      end

      it 'increase vault items count' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, user_name: 'password')
        params = Hash["#{item}_id".to_sym, vault_item.to_param]
        expect do
          item.camelize.constantize::Operation::Copy.call({ params: params }.merge(copy_item_options))
        end.to change(VaultItem, :count).by(1)
      end
    end
  end

  describe 'Move vault item' do
    let(:target_vault) { create_shared_vault(admin) }
    let(:move_item_options) { { current_user: admin, vault: shared_vault, target_vault: target_vault } }

    %w[login_item credit_card_item server_item].each do |item|
      it 'vault_item does not exist' do
        params = Hash["#{item}_id".to_sym, 'invalid']
        result = item.camelize.constantize::Operation::Move.call({ params: params }.merge(move_item_options))
        assert result['result.model'].failure?
      end

      it 'gets forbidden' do
        params = Hash["#{item}_id".to_sym, create(item.to_sym, vault: shared_vault, only_for_admins: true).to_param]
        user_options = { current_user: user, vault: shared_vault, target_vault: target_vault }
        result = item.camelize.constantize::Operation::Move.call({ params: params }.merge(user_options))
        assert result['result.policy.default'].failure?
      end

      it 'gets forbidden for support' do
        params = Hash["#{item}_id".to_sym, create(item.to_sym, vault: shared_vault, only_for_admins: true).to_param]
        support_options = { current_user: support, vault: shared_vault, target_vault: target_vault }
        result = item.camelize.constantize::Operation::Move.call({ params: params }.merge(support_options))
        assert result['result.policy.default'].failure?
      end

      it 'gets success' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, user_name: 'password')
        params = Hash["#{item}_id".to_sym, vault_item.to_param]
        result = item.camelize.constantize::Operation::Move.call({ params: params }.merge(move_item_options))
        assert result['result.model'].success?
        expect(vault_item.reload.vault_id).to eq(target_vault.id)
      end

      it 'creates activity' do
        vault_item = create_vault_item(item.to_sym, admin, shared_vault, user_name: 'password')
        params = Hash["#{item}_id".to_sym, vault_item.to_param]
        expect do
          item.camelize.constantize::Operation::Move.call({ params: params }.merge(move_item_options))
        end.to change(Activity, :count).by(+1)
      end
    end
  end
end
