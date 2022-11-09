# frozen_string_literal: true
#
require 'rails_helper'

RSpec.describe Document, entity_type: :operation do
  let(:file) { File.new("#{Rails.root}/spec/support/fixtures/test.txt") }
  let(:team) { create(:team, name: FFaker::Name.unique.name) }
  let(:admin) { create_user(:admin, team: team) }
  let(:document) { create(:document, vault_item: server_item) }
  let(:document_decrypted) { create(:document, vault_item: server_item, encrypted: false) }
  let(:server_item) { create(:server_item) }
  let(:default_options) { { current_user: admin, vault_item: document.vault_item } }

  describe 'Show document' do
    it 'get success' do
      params = { id: document.to_param }
      result = Document::Operation::Show.call({ params: params }.merge(default_options))
      assert result['result.model'].success?
    end

    it 'document does not exist' do
      params = { id: 'invalid' }
      result = Document::Operation::Show.call({ params: params }.merge(default_options))
      assert result['result.model'].failure?
    end

    it 'write activity' do
      params = { id: document.to_param }
      expect do
        Document::Operation::Show.call({ params: params }.merge(default_options))
      end.to change(Activity, :count).by(+1)
    end
  end

  describe 'Create document' do
    subject(:result) { Document::Operation::Create.call({ params: default_params }.merge(default_options)) }

    let(:default_params) { Hash[:document, { file: file }] }
    let(:default_options) { { current_user: admin, vault_item: document.vault_item } }

    it 'document is valid' do
      assert result.success?
    end

    it 'document is invalid' do
      params = Hash[:document, { file: '' }]
      result = Document::Operation::Create.call({ params: params }.merge(default_options))
      assert result.failure?
    end

    it 'write activity' do
      expect { result }.to change(Activity, :count).by(+1)
    end
  end

  describe 'Update document' do
    it 'document is updated' do
      params = Hash[:document, { file: file }].merge(id: document.id)
      result = Document::Operation::Update.call({ params: params }.merge(default_options))
      assert result.success?
    end

    it 'document is invalid' do
      params = Hash[:document, { file: '' }].merge(id: document.id)
      result = Document::Operation::Update.call({ params: params }.merge(default_options))
      assert result.failure?
    end

    it 'document does not exist' do
      params = Hash[:document, {}].merge(id: 'invalid')
      result = Document::Operation::Update.call({ params: params }.merge(default_options))
      assert result['result.model'].failure?
    end

    it 'write activity' do
      params = Hash[:document, { file: file }].merge(id: document.id)
      expect do
        Document::Operation::Update.call({ params: params }.merge(default_options))
      end.to change(Activity, :count).by(+1)
    end
  end

  describe 'Destroy document' do
    it 'document does not exist' do
      params = { id: 'invalid' }
      result = Document::Operation::Destroy.call({ params: params }.merge(default_options))
      assert result['result.model'].failure?
    end

    it 'document is valid' do
      params = { id: document.to_param }
      result = Document::Operation::Destroy.call({ params: params }.merge(default_options))
      assert result.success?
    end

    it 'write activity' do
      params = { id: document.to_param }
      expect do
        Document::Operation::Destroy.call({ params: params }.merge(default_options))
      end.to change(Activity, :count).by(+1)
    end
  end
end
