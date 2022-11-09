# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Vaults' do
  let(:team) { create :team, name: 'team' }

  path '/api/v1/vaults' do
    get 'Shows vaults' do
      tags 'Vaults'
      consumes 'application/json'

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault1)         { create_shared_vault signed_in_user }
      let(:vault2)         { create_shared_vault signed_in_user }

      response '200', 'vault find' do
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{id}' do
    get 'Shows vault' do
      tags 'Vaults'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }

      response '200', 'vault find' do
        let(:id) { vault.id }
        run_test!
      end

      response '404', 'vault not found' do
        let(:id) { '111' }
        run_test!
      end
    end
  end

  path '/api/v1/vaults' do
    post 'Creates a vault' do
      tags 'Vaults'
      consumes 'application/json'
      parameter name: :vault, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string }
        }, required: %w[title description]
      }

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }

      response '201', 'vault created' do
        let(:vault) { { title: 'name', description: 'test' } }
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{id}' do
    put 'Updates a vault' do
      tags 'Vaults'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :vault, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string }
        },
        required: %w[title description]
      }

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }

      response '200', 'vault updated' do
        let(:id) { vault.id }
        let(:params) { { vault: { title: 'name1' } } }
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{id}' do
    delete 'Destroyed a vault' do
      tags 'Vaults'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string, required: true

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }

      response '204', 'vault destroyed' do
        let(:id) { vault.id }
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{id}/vault_items' do
    get 'Shows vault items' do
      tags 'Vault items'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }
      let(:login_item1) { create(:login_item) }
      let(:login_item2) { create(:login_item) }

      before do
        vault.vault_items.push(login_item1, login_item2)
      end

      response '200', 'vault find' do
        let(:id) { vault.id }
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{id}/generate_report' do
    post 'Generate report' do
      tags 'Vaults'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :user_id, in: :query, type: :string, required: true

      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }

      response '200', 'report generated' do
        let(:id) { vault.id }
        let(:user_id) { create(:user, team: team).id }
        run_test!
      end
    end
  end
end
