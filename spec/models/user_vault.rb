# frozen_string_literal: true

RSpec.describe UserVault, entity_type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:vault) }
  end
end
