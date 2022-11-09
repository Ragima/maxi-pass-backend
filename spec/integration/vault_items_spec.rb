# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vault Items' do
  %w[login_item credit_card_item server_item].each do |vault_item|
    path "/api/v1/vaults/{vault_id}/#{vault_item}s/{id}" do
      get "Show #{vault_item}" do
        tags "Vault Items"
        consumes 'application/json'
        parameter name: :vault_id, in: :path, type: :string
        parameter name: :id, in: :path, type: :string

        let(:team) { create :team, name: 'team'}
        let(:signed_in_user) { create_user :admin, team: team }
        let(:vault) { create_shared_vault signed_in_user }
        let(:item) { create_vault_item vault_item.to_sym, signed_in_user, vault, some_field: 'some_value' }
        let(:vault_id) { vault.id }
        let(:id) { item.id }

        response '200', "#{vault_item} show" do
          run_test!
        end
      end
    end

    path "/api/v1/vaults/{vault_id}/#{vault_item}s" do
      post "Create #{vault_item}" do
        tags "Vault Items"
        consumes 'application/json'
        parameter name: :vault_id, in: :path, type: :string
        parameter name: vault_item.to_sym, in: :body, schema: {
            type: :object,
            properties: {
                title: { type: :string },
                tags: { type: :string },
                only_for_admins: { type: :boolean },
                dynamic_key: { type: :string }
            }
        }

        let(:team) { create :team, name: 'team'}
        let(:signed_in_user) { create_user :admin, team: team }
        let(:vault) { create_shared_vault signed_in_user }
        let(:item) { create_vault_item vault_item.to_sym, signed_in_user, vault, some_field: 'some_value' }
        let(:vault_id) { vault.id }
        let(:id) { item.id }

        response '201', "#{vault_item} create" do
          let(vault_item.to_sym) { { title: "Test", tags: "test1 test2", only_for_admins: false, dynamic_key: 'value' } }
          run_test!
        end
      end
    end

    path "/api/v1/vaults/{vault_id}/#{vault_item}s/{id}" do
      put "Update #{vault_item}" do
        tags "Vault Items"
        consumes 'application/json'
        parameter name: :vault_id, in: :path, type: :string
        parameter name: :id, in: :path, type: :string
        parameter name: vault_item.to_sym, in: :body, schema: {
            type: :object,
            properties: {
                title: { type: :string },
                tags: { type: :string },
                only_for_admins: { type: :boolean },
                dynamic_key: { type: :string }
            }
        }

        let(:team) { create :team, name: 'team' }
        let(:signed_in_user) { create_user :admin, team: team }
        let(:vault) { create_shared_vault signed_in_user }
        let(:item) { create_vault_item vault_item.to_sym, signed_in_user, vault, some_field: 'some_value' }
        let(:vault_id) { vault.id }
        let(:id) { item.id }

        response '200', "#{vault_item} update" do
          let(vault_item.to_sym) { { title: "Test", tags: "test1 test2", only_for_admins: false, dynamic_key: 'value' } }
          run_test!
        end
      end
    end

    path "/api/v1/vaults/{vault_id}/#{vault_item}s/{id}" do
      delete "Destroy #{vault_item}" do
        tags "Vault Items"
        consumes 'application/json'
        parameter name: :vault_id, in: :path, type: :string
        parameter name: :id, in: :path, type: :string
        let(:team) { create :team, name: 'team' }
        let(:signed_in_user) { create_user :admin, team: team }
        let(:vault) { create_shared_vault signed_in_user }
        let(:item) { create_vault_item vault_item.to_sym, signed_in_user, vault, some_field: 'some_value' }
        let(:vault_id) { vault.id }
        let(:id) { item.id }

        response '204', "#{vault_item} update" do
          run_test!
        end
      end
    end

    path "/api/v1/vaults/{vault_id}/#{vault_item}s/{#{vault_item}_id}/copy" do
      parameter name: :vault_id, in: :path, type: :string
      parameter name: "#{vault_item}_id".to_sym, in: :path, type: :string
      parameter name: :target_vault_id, in: :body, required: true, schema: {
        type: :object,
        properties: {
          target_vault_id: { type: :string }
        }
      }
      post "Copy #{vault_item}" do
        tags "Vault Items"
        consumes 'application/json'
        produces 'application/json'
        let(:team) { create :team, name: 'team' }
        let(:signed_in_user) { create_user :admin, team: team }
        let(:vault) { create_shared_vault signed_in_user }
        let(:target_vault) { create_shared_vault signed_in_user }
        let(:item) { create_vault_item vault_item.to_sym, signed_in_user, vault, some_field: 'some_value' }
        let(:target_vault_id) { { target_vault_id: target_vault.id } }
        let(:vault_id) { vault.id }
        let("#{vault_item}_id".to_sym) { item.id }

        response '204', "#{vault_item} copy" do
          run_test!
        end
      end
    end

    path "/api/v1/vaults/{vault_id}/#{vault_item}s/{#{vault_item}_id}/move" do
      parameter name: :vault_id, in: :path, type: :string
      parameter name: "#{vault_item}_id".to_sym, in: :path, type: :string
      parameter name: :target_vault_id, in: :body, required: true, schema: {
        type: :object,
        properties: {
          target_vault_id: { type: :string }
        }
      }
      post "Move #{vault_item}" do
        tags "Vault Items"
        consumes 'application/json'
        produces 'application/json'
        let(:team) { create :team, name: 'team' }
        let(:signed_in_user) { create_user :admin, team: team }
        let(:vault) { create_shared_vault signed_in_user }
        let(:target_vault) { create_shared_vault signed_in_user }
        let(:item) { create_vault_item vault_item.to_sym, signed_in_user, vault, some_field: 'some_value' }
        let(:target_vault_id) { { target_vault_id: target_vault.id } }
        let(:vault_id) { vault.id }
        let("#{vault_item}_id".to_sym) { item.id }

        response '204', "#{vault_item} copy" do
          run_test!
        end
      end
    end
  end
end