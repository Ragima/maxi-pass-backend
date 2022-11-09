# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, entity_type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:vaults) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:services) }
  end

  describe 'db column' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
  end

  context 'with basic validation presence_of' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'validation' do
    let(:team)            { build(:team) }
    let(:user)            { build(:user, team: team) }
    let(:invalid_team)    { build(:team, name: '') }

    context 'with presence_of' do
      it { is_expected.to validate_presence_of(:name) }
    end

    it 'with valid params' do
      expect(team).to be_valid
    end

    it 'with blank name' do
      expect(invalid_team).not_to be_valid
    end
  end
end
