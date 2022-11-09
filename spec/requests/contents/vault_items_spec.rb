# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'vault_items', entity_type: :request do
  let(:user) { create :user }

  describe 'get #index' do
    sign_in :user
    it 'returns success' do
      get '/vault_items'
      expect(response).to have_http_status(:ok)
    end
  end
end
