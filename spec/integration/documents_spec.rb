# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Documents' do

  let(:file) { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/support/fixtures/test.txt'))) }

  path '/api/v1/vaults/{vault_id}/server_items/{vault_item_id}/documents' do
    post 'Create Document' do
      tags 'Documents'
      produces 'application/json'
      consumes 'multipart/form-data'
      parameter name: :vault_id, in: :path, type: :string, required: true
      parameter name: :vault_item_id, in: :path, type: :string, required: true
      parameter name: :document, in: :formData, schema: {
        type: :object,
        properties: {
          file: {
            type: :file

          }
        }, required: %w[file]
      }

      let(:team) { create :team, name: 'team'}
      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }
      let(:item) { create_vault_item :server_item, signed_in_user, vault, some_field: 'some_value' }
      let(:vault_item_id) { item.id }
      let(:vault_id) { item.vault.id }

      response '201', 'create document' do
        let(:document) { { file: file } }
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{vault_id}/server_items/{vault_item_id}/documents/{id}' do
    delete 'Destroy document' do
      tags 'Document'
      consumes 'application/json'
      parameter name: :vault_id, in: :path, type: :string, required: true
      parameter name: :vault_item_id, in: :path, type: :string, required: true
      parameter name: :id, in: :path, type: :string, required: true

      let(:team) { create :team, name: 'team'}
      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }
      let!(:item) { create_vault_item :server_item, signed_in_user, vault, some_field: 'some_value' }

      let(:vault_item_id) { item.id }
      let(:vault_id) { item.vault.id }
      let(:id) { document.id }
      let(:document) { create :document, vault_item: item }

      response '204', 'Delete document' do
        run_test!
      end
    end
  end

  path '/api/v1/vaults/{vault_id}/server_items/{vault_item_id}/documents/{id}' do
    put 'Update  Document' do
      tags 'Documents'
      produces 'application/json'
      consumes 'multipart/form-data'
      parameter name: :vault_id, in: :path, type: :string, required: true
      parameter name: :vault_item_id, in: :path, type: :string, required: true
      parameter name: :id, in: :path, type: :string, required: true
      parameter name: :document, in: :formData, schema: {
          type: :object,
          properties: {
            file: {
              type: :file
            }
          }, required: %w[file]
      }

      let(:team) { create :team, name: 'team'}
      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault) { create_shared_vault signed_in_user }
      let!(:item) { create_vault_item :server_item, signed_in_user, vault, some_field: 'some_value' }

      let(:vault_item_id) { item.id }
      let(:vault_id) { item.vault.id }
      let(:id) { document_old.id }
      let(:document_old) { create :document, vault_item: item }

      response '200', 'Updated document' do
        let(:document) { { file: file } }
        run_test!
      end
    end
  end
end

