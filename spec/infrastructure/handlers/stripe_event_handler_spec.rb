require 'rails_helper'

RSpec.describe Handlers::StripeEventHandler, type: :module do
  let(:stripe_event) { create(:stripe_event, event_type: event_type, payload: payload) }

  describe '.process_event' do
    context 'when the event type is customer.subscription.created' do
      let(:event_type) { 'customer.subscription.created' }
      let(:payload) { JSON.parse(File.read('spec/support/stripe_webhooks/customer_subscription_created.json')) }

      it 'calls the CreateSubscription use case and returns :processed' do
        allow(UseCases::CreateSubscription).to receive(:new).and_return(double(call: Result.success))
        
        result = described_class.process_event(stripe_event)
        expect(result).to eq(:processed)
      end
    end

    context 'when the event type is invoice.payment_succeeded' do
      let(:event_type) { 'invoice.payment_succeeded' }
      let(:payload) { JSON.parse(File.read('spec/support/stripe_webhooks/invoice_payment_succeeded.json')) }

      it 'calls the MarkSubscriptionAsPaid use case and returns :processed' do
        allow(UseCases::MarkSubscriptionAsPaid).to receive(:new).and_return(double(call: Result.success))
        
        result = described_class.process_event(stripe_event)
        expect(result).to eq(:processed)
      end
    end

    context 'when the event type is customer.subscription.deleted' do
      let(:event_type) { 'customer.subscription.deleted' }
      let(:payload) { JSON.parse(File.read('spec/support/stripe_webhooks/customer_subscription_deleted.json')) }

      it 'calls the CancelSubscription use case and returns :processed' do
        allow(UseCases::CancelSubscription).to receive(:new).and_return(double(call: Result.success))
        
        result = described_class.process_event(stripe_event)
        expect(result).to eq(:processed)
      end
    end

    context 'when the event type is unhandled' do
      let(:event_type) { 'customer.updated' }
      let(:payload) { JSON.parse(File.read('spec/support/stripe_webhooks/customer_updated.json')) }

      it 'returns :unhandled' do
        result = described_class.process_event(stripe_event)
        expect(result).to eq(:unhandled)
      end
    end

    context 'when an error occurs during processing' do
      let(:event_type) { 'customer.subscription.created' }
      let(:payload) { JSON.parse(File.read('spec/support/stripe_webhooks/customer_subscription_created.json')) }

      it 'returns :error' do
        allow(UseCases::CreateSubscription).to receive(:new).and_raise(StandardError, 'Something went wrong')

        result = described_class.process_event(stripe_event)
        expect(result).to eq(:error)
      end
    end
  end
end
