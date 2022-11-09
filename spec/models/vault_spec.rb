# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vault, entity_type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team).optional }
    it { is_expected.to have_many(:group_vaults) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:user_vaults) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:vault_items) }
  end

  describe 'method test' do
    let(:team) { create :team, name: 'team' }
    let(:user) { create :user, team: team }
    let(:vault1) { create_shared_vault user, team: team }
    let(:item) { create_vault_item :login_item, user, vault1, some_field: 'some_value' }
    let(:item2) { create_vault_item :login_item, user, vault1, some_field: 'some_value2' }

    before do
      vault1.vault_items.push(item, item2)
    end

    it 'generate file' do
      Vault.generate_report(vault1, "#{Rails.root}/tmp/vault_#{vault1.title}_information.pdf")
      File.exist?("#{Rails.root}/tmp/group_#{vault1.title}_information.pdf")
    end

    after(:all) do
      FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
    end
  end
end
