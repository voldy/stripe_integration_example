require 'rails_helper'

RSpec.describe Handlers::StripeWebhookHandler, type: :service do
  include ActiveJob::TestHelper

  let(:event) { { 'id' => 'evt_test', 'type' => 'payment_intent.succeeded', 'data' => { 'object' => {} } } }

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '.process' do
    context 'when the event is a new record' do
      it 'creates a StripeEvent record and schedules a job' do
        expect {
          Handlers::StripeWebhookHandler.process(event)
        }.to change(StripeEvent, :count).by(1)
        expect(ProcessStripeEventJob).to have_been_enqueued.with(StripeEvent.last.id)
      end
    end

    context 'when the event is not a new record' do
      let!(:existing_event) { 
        StripeEvent.create!(
          event_id: 'evt_test', event_type: 'payment_intent.succeeded', payload: event, status: 'pending') }

      it 'does not schedule a job' do
        expect {
          Handlers::StripeWebhookHandler.process(event)
        }.not_to change(StripeEvent, :count)  # Ensure no new StripeEvent is created
        expect(ProcessStripeEventJob).not_to have_been_enqueued  # Ensure no job is scheduled

        # Ensure the existing event is not updated
        expect(existing_event.reload.status).to eq('pending')
      end
    end
  end
end
