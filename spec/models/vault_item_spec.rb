# frozen_string_literal: true

RSpec.describe VaultItem, entity_type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:vault) }
    it { is_expected.to have_many(:documents).dependent(:destroy) }
  end
end
