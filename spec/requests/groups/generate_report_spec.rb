# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'report', entity_type: :request do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:user) { create :user, team: team }
  let(:lead) { create :user, team: team }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group) { create :group, name: 'inner_group1', parent: group, team: team }
  let(:inner_group2) { create :group, name: 'inner_group2', parent: inner_group, team: team }
  let(:inner_group3) { create :group, name: 'inner_group3', parent: inner_group2, team: team }
  let(:group2) { create :group, name: 'group3', team: team }
  let(:foreign_group) { create :group, name: 'group4', team: create(:team) }
  let(:shared_vault1) { create :shared_vault, user: admin, team: team }
  let(:shared_vault2) { create :shared_vault, user: admin, team: team }
  let(:shared_vault3) { create :shared_vault, user: admin, team: team }
  let(:shared_vault4) { create :shared_vault, user: admin, team: team }
  let(:item1) { create_vault_item :login_item, admin, shared_vault1, some_field: 'some_value' }
  let(:item2) { create_vault_item :login_item, admin, shared_vault1, some_field: 'some_value2' }
  let(:item3) { create_vault_item :login_item, admin, shared_vault2, some_field: 'some_value3' }
  let(:item4) { create_vault_item :login_item, admin, shared_vault2, some_field: 'some_value4' }
  let(:item5) { create_vault_item :login_item, admin, shared_vault2, some_field: 'some_value5' }
  let(:item6) { create_vault_item :login_item, admin, shared_vault4, some_field: 'some_value5' }

  describe 'get #generate_report' do
    context 'when group not present' do
      let(:group2) { create :group, name: 'group2' }

      sign_in :admin
      before do
        post "/api/v1/groups/#{group2.id}/generate_report",
            params: {
                user_id: user.id
            }
      end

      it { expect(response).to have_http_status 404 }
    end

    context 'with authorized user' do
      sign_in :admin

      before do
        group.group = inner_group
        inner_group.group = inner_group2
        inner_group2.group = inner_group3
        group.vaults.push(shared_vault1, shared_vault3)
        inner_group.vaults << shared_vault2
        inner_group2.vaults << shared_vault3
        inner_group3.vaults << shared_vault4
        shared_vault1.vault_items.push(item1, item2)
        shared_vault2.vault_items.push(item3, item4, item5)
        shared_vault4.vault_items.push(item6)

        post "/api/v1/groups/#{group.id}/generate_report",
            params: {
                user_id: user.id
            }
      end

      it { expect(response).to have_http_status 200 }

      after(:all) do
        FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
      end
    end
  end
end
