require 'rails_helper'

RSpec.describe EnableTwoFactorJob, type: :job do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:user_ids) { [user.id, user2.id] }

  subject(:job) { EnableTwoFactorJob.perform_later(user_ids) }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(EnableTwoFactorJob).on_queue('two_factor')
  end

  it 'is in report queue' do
    expect(EnableTwoFactorJob.new.queue_name).to eq('two_factor')
  end
end
