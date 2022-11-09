# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, entity_type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:team).optional }
    it { is_expected.to have_many(:group_users) }
  end

  describe 'method generate_report' do
    let(:team) { create :team, name: 'team' }
    let(:admin) { create :admin, team: team }
    let(:group) { create :group, name: 'group', team: team }
    before do
      admin.groups << group
    end

    it 'generate file' do
      User.generate_report(admin, "#{Rails.root}/tmp/group_#{admin.name}_information.pdf")
      File.exist?("#{Rails.root}/tmp/group_#{admin.name}_information.pdf")
    end

    after(:all) do
      FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
    end
  end
end
