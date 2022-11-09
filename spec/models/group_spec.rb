# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, entity_type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team) }
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:group_users) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:group_vaults) }
    it { is_expected.to have_many(:vaults) }
  end

  describe 'db column' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
  end

  describe 'method generate_report' do
    let(:team) { create :team, name: 'team' }
    let(:group) { create :group, name: 'group', team: team }
    let(:inner_group) { create :group, name: 'inner_group1', parent: group, team: team }
    before do
      group.group = inner_group
    end

    it 'generate file' do
      Group.generate_report(group, "#{Rails.root}/tmp/group_#{group.name}_information.pdf")
      File.exist?("#{Rails.root}/tmp/group_#{group.name}_information.pdf")
    end

    after(:all) do
      FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
    end
  end
end
