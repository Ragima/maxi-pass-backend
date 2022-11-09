require 'rails_helper'

RSpec.describe ReportJob, type: :job do
  let(:team) { create :team, name: 'team' }
  let(:admin) { create :admin, team: team }
  let(:user) { create :admin, team: team }
  let(:group) { create :group, name: 'group', team: team }

  subject(:job) { ReportJob.perform_later(group.id, user.id, admin.id, 'Group') }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(ReportJob).on_queue('report')
  end

  it 'is in report queue' do
    expect(ReportJob.new.queue_name).to eq('report')
  end
end
