require 'rails_helper'

RSpec.describe Billing::Services::SubscriptionService, type: :service do
  let(:repository) { instance_double(Billing::Repositories::SubscriptionRepository) }
  let(:event_publisher) { instance_double(Billing::EventPublisher) }
  let(:subscription_service) { described_class.new(repository, event_publisher) }
  let(:subscription) { instance_double(Billing::Entities::Subscription, id: 'sub_123', customer_id: 'cus_123', status: 'unpaid') }

  describe '#create_subscription' do
    it 'creates and saves a new subscription with an unpaid status and publishes SubscriptionCreatedEvent' do
      allow(Billing::Entities::Subscription).to receive(:new).and_return(subscription)
      
      expect(repository).to receive(:save).with(subscription)
      expect(event_publisher).to receive(:publish).with(instance_of(Billing::Events::SubscriptionCreatedEvent))

      response = subscription_service.create_subscription(id: 'sub_123', customer_id: 'cus_123')
      created_subscription = response.value

      expect(response).to be_success
      expect(created_subscription).to eq(subscription)
      expect(created_subscription.status).to eq('unpaid') 
    end
  end

  describe '#mark_subscription_as_paid' do
    let(:result) { instance_double(Result, success?: true) }

    context 'when the subscription is found and marked as paid' do
      before do
        allow(repository).to receive(:find_by_id).with('sub_123').and_return(subscription)
        allow(subscription).to receive(:mark_as_paid).and_return(result)
      end

      it 'marks the subscription as paid and publishes PaymentSucceededEvent' do
        expect(repository).to receive(:save).with(subscription)
        expect(event_publisher).to receive(:publish).with(instance_of(Billing::Events::PaymentSucceededEvent))

        response = subscription_service.mark_subscription_as_paid('sub_123')
        expect(response).to be_success
      end
    end

    context 'when the subscription is not found' do
      before do
        allow(repository).to receive(:find_by_id).with('sub_123').and_return(nil)
      end

      it 'returns a failure result' do
        response = subscription_service.mark_subscription_as_paid('sub_123')
        expect(response).to be_failure
        expect(response.error).to eq('Subscription not found')
      end
    end
  end

  describe '#cancel_subscription' do
    let(:result) { instance_double(Result, success?: true) }

    context 'when the subscription is found and canceled' do
      before do
        allow(repository).to receive(:find_by_id).with('sub_123').and_return(subscription)
        allow(subscription).to receive(:cancel).and_return(result)
      end

      it 'cancels the subscription and publishes SubscriptionCanceledEvent' do
        expect(repository).to receive(:save).with(subscription)
        expect(event_publisher).to receive(:publish).with(instance_of(Billing::Events::SubscriptionCanceledEvent))

        response = subscription_service.cancel_subscription('sub_123')
        expect(response).to be_success
      end
    end

    context 'when the subscription is not found' do
      before do
        allow(repository).to receive(:find_by_id).with('sub_123').and_return(nil)
      end

      it 'returns a failure result' do
        response = subscription_service.cancel_subscription('sub_123')
        expect(response).to be_failure
        expect(response.error).to eq('Subscription not found')
      end
    end
  end
end
