# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserInformationPdf, entity_type: :class do
  subject(:result) { UserInformationPdf.new(user).user_table }

  let(:team) { create :team, name: 'team' }
  let(:user) { create :user, team: team }
  let(:group) { create :group, name: 'group', team: team }
  let(:inner_group1) { create :group, name: 'inner_group1', parent: group, team: team }
  let(:inner_group2) { create :group, name: 'inner_group2', parent: inner_group1, team: team }
  let(:inner_group3) { create :group, name: 'inner_group3', parent: inner_group2, team: team }
  let(:shared_vault1) { create :shared_vault, team: team, title: 'shared_vault1' }
  let(:shared_vault2) { create :shared_vault, team: team, title: 'shared_vault2' }
  let(:shared_vault3) { create :shared_vault, team: team, title: 'shared_vault3' }
  let(:shared_vault4) { create :shared_vault, team: team, title: 'shared_vault4' }
  let(:shared_vault5) { create :shared_vault, team: team, title: 'shared_vault5' }
  let(:shared_vault6) { create :shared_vault, team: team, title: 'shared_vault6' }
  let(:item1) { create :login_item, vault: shared_vault1, title: 'item1' }
  let(:item2) { create :login_item, vault: shared_vault1, title: 'item2' }
  let(:item3) { create :login_item, vault: shared_vault2, title: 'item3' }
  let(:item4) { create :login_item, vault: shared_vault2, title: 'item4' }
  let(:item5) { create :login_item, vault: shared_vault3, title: 'item5' }
  let(:item6) { create :login_item, vault: shared_vault3, title: 'item6' }
  let(:item7) { create :login_item, vault: shared_vault5, title: 'item7' }

  describe 'create groups table' do
    before do
      group.vaults.push(shared_vault1, shared_vault3)
      inner_group1.vaults << shared_vault2
      inner_group2.vaults << shared_vault3
      inner_group3.vaults << shared_vault4
      user.vaults.push(shared_vault5, shared_vault6)
      item1
      item2
      item3
      item4
      item5
      item6
      item7
      user.groups.push(group, inner_group1, inner_group2, inner_group3)
    end

    it { expect(result[0]).to match_array(%w[Groups Vaults Items]) }
    it { expect(result[1]).to match_array(['group', 'shared_vault1', 'item1 (LoginItem)']) }
    it { expect(result.last).to match_array(['', 'shared_vault6', '']) }
  end
end
