require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:vault_item) }
    it { is_expected.to have_attached_file(:file) }
  end

  describe 'db column' do
    it { is_expected.to have_db_column(:content).of_type(:text) }
  end

  context 'with basic validation presence_of' do
    it { is_expected.to validate_attachment_presence(:file) }
    it { is_expected.to validate_attachment_size(:file).less_than(1.megabytes) }
  end

  describe 'validation' do
    let(:valid_document) { build(:document) }
    let(:invalid_document) { build(:document, file: '') }

    it 'with valid params' do
      expect(valid_document).to be_valid
    end

    it 'with blank name' do
      expect(invalid_document).not_to be_valid
    end
  end
end

