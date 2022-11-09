# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, entity_type: :model do
  describe 'method generate_report' do
    let(:team)      { create :team, name: 'team' }
    let(:admin)     { create :admin, team: team }
    let(:activity1) { create :activity, trackable_id: admin.id, team_name: team.name, actor_email: admin.email }
    let(:activity2) { create :activity, trackable_id: admin.id, team_name: team.name, actor_email: admin.email }

    it 'generate file' do
      Activity.generate_report("#{Rails.root}/tmp/team_#{team.try(:name)}_activity_structure_report.pdf",
                               { activity_type: 'Login'},
                               [activity1, activity2])
      File.exist?("#{Rails.root}/tmp/team_#{team.try(:name)}_activity_structure_report.pdf")
    end

    after(:all) do
      FileUtils.rm_rf(Dir.glob('tmp/*.pdf'))
    end
  end
end
