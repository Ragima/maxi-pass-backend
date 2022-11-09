# frozen_string_literal: true

RSpec.describe Service, entity_type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:team).optional }
  end
end
