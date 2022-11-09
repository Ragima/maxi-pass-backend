# frozen_string_literal: true

RSpec.describe GroupVault, entity_type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:vault) }
  end
end
