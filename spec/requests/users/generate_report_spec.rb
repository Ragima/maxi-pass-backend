# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'report', entity_type: :request do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:admin2) { create :admin, team: team }
  let(:user) { create :user, team: team }
  let(:lead) { create :user, team: team }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'inner_group1', parent: group, team: team }
  let(:inner_group2) { create :group, name: 'inner_group2', parent: inner_group, team: team }
  let(:shared_vault1) { create :shared_vault, user: admin, team: team }
  let(:shared_vault2) { create :shared_vault, user: admin, team: team }
  let(:item1) { create_vault_item :login_item, admin, shared_vault1, some_field: 'some_value' }
  let(:item4) { create_vault_item :login_item, admin, shared_vault2, some_field: 'some_value4' }
  let(:item5) { create_vault_item :login_item, admin, shared_vault2, some_field: 'some_value5' }

  describe 'get #generate_report' do
    context 'when target user is admin' do
      sign_in :user
      before do
        post "/api/v1/users/#{admin.id}/generate_report",
             params: {
                 report_receiver_id: admin.id
             }
      end

      it { expect(response).to have_http_status 403 }
    end

    context 'when target user exist in another team' do
      let(:team2) { create :team, name: 'team2' }
      let(:user2) { create :user, team: team2 }

      sign_in :admin
      before do
        post "/api/v1/users/#{user2.id}/generate_report"
      end

      it { expect(response).to have_http_status 404 }
    end

    context 'with authorized user' do
      sign_in :admin2

      before do
        admin.groups.push(group, inner_group, inner_group2)
        group.group = inner_group
        inner_group.group = inner_group2
        group.vaults << shared_vault1
        inner_group.vaults << shared_vault2
        shared_vault1.vault_items << item1
        shared_vault2.vault_items.push(item4, item5)

        post "/api/v1/users/#{admin.id}/generate_report",
             params: {
                 report_receiver_id: user.id
             }
      end

      it { expect(response).to have_http_status 200 }

      after(:all) do
        FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
      end
    end
  end
end
