require 'rails_helper'

RSpec.describe ProcessStripeEventJob, type: :job do
  let(:stripe_event) { create(:stripe_event) }

  describe '#perform' do
    before do
      allow(Handlers::StripeEventHandler).to receive(:process_event).and_return(:processed)
    end

    it 'processes the stripe event and updates the status to processed' do
      allow_any_instance_of(StripeEvent).to receive(:update!).with(status: 'processed', processed_at: kind_of(Time))
      expect(Handlers::StripeEventHandler).to receive(:process_event).with(stripe_event).and_return(:processed)

      described_class.new.perform(stripe_event.id)
    end

    it 'updates the status to unhandled if the event is not processed' do
      allow(Handlers::StripeEventHandler).to receive(:process_event).and_return(:unhandled)
      allow_any_instance_of(StripeEvent).to receive(:update!).with(status: 'unhandled')

      described_class.new.perform(stripe_event.id)
    end

    it 'updates the status to failed if there is an error processing the event' do
      allow(Handlers::StripeEventHandler).to receive(:process_event).and_return(:error)
      allow_any_instance_of(StripeEvent).to receive(:update!).with(status: 'failed')

      described_class.new.perform(stripe_event.id)
    end

    it 'raises an error if the StripeEvent record is not found' do
      expect {
        described_class.new.perform(nil)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
