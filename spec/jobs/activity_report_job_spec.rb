require 'rails_helper'

RSpec.describe ActivityReportJob, type: :job do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:user) { create :admin, team: team }
  let(:activity) { create :activity, trackable_id: admin.id, team_name: team.name, actor_email: admin.email }
  let(:activity2) { create :activity, trackable_id: admin.id, team_name: team.name, actor_email: admin.email }

  subject(:job) { ActivityReportJob.perform_later(user.id, admin.id, 'Activity', { activity_type: 'Login'}, *[activity, activity2]) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ActivityReportJob).on_queue('report')
  end

  it 'is in report queue' do
    expect(ActivityReportJob.new.queue_name).to eq('report')
  end
end
