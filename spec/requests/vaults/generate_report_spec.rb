# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'report', entity_type: :request do
  let!(:team) { create :team, name: 'team' }

  describe 'get #generate_report' do
    context 'with not verified user' do
      let(:user) { create(:user) }
      let(:vault1) { create_shared_vault user }

      before do
        post "/api/v1/vaults/#{vault1.id}/generate_report",
            params: {
              user_id: user.id
            }
      end

      it { expect(response).to have_http_status 401 }
    end

    context 'with authorized user' do
      let(:signed_in_user) { create_user :admin, team: team }
      let(:vault1) { create_shared_vault signed_in_user, team: team }
      let(:user) { create :user, team: team }
      let(:item) { create_vault_item :login_item, signed_in_user, vault1, some_field: 'some_value' }
      let(:item2) { create_vault_item :login_item, signed_in_user, vault1, some_field: 'some_value2' }

      sign_in :signed_in_user
      before do
        vault1.vault_items.push(item, item2)
        vault1.users << user

        post "/api/v1/vaults/#{vault1.id}/generate_report",
            params: {
              user_id: user.id
            }
      end

      it { expect(response).to have_http_status 200 }
    end
  end

  context 'when user not present in vault' do
    let(:signed_in_user) { create_user :admin, team: team }
    let(:vault1)         { create_shared_vault signed_in_user }
    let(:user)           { create(:user) }

    sign_in :signed_in_user
    before do
      post "/api/v1/vaults/#{vault1.id}/generate_report",
          params: {
            user_id: user.id
          }
    end

    it { expect(response).to have_http_status 404 }
  end

  context 'when vault not present' do
    let(:signed_in_user) { create_user :admin, team: team }
    let(:vault1)         { create_shared_vault signed_in_user }
    let(:vault2)         { create :vault }
    let(:user)           { create(:user) }

    sign_in :signed_in_user
    before do
      vault1.users << user
      post "/api/v1/vaults/#{vault2.id}/generate_report",
          params: {
            user_id: user.id
          }
    end

    it { expect(response).to have_http_status 404 }

    after(:all) do
      FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
    end
  end
end
