require 'rails_helper'

RSpec.describe Billing::EventPublisher, type: :model do
  let(:event_publisher) { Billing::EventPublisher.instance }

  let(:payment_event) { Billing::Events::PaymentSucceededEvent.new(subscription_id: 'sub_123', customer_id: 'cus_123') }
  let(:subscription_event) { Billing::Events::SubscriptionCanceledEvent.new(subscription_id: 'sub_456', customer_id: 'cus_456', status: 'canceled') }

  before(:each) do
    event_publisher.clear_subscribers
  end

  describe '#subscribe' do
    it 'registers a subscriber for an event class' do
      subscriber = double('Subscriber', call: nil)
      event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, subscriber)

      expect { event_publisher.publish(payment_event) }.not_to raise_error
    end
  end

  describe '#publish' do
    it 'notifies the subscriber when the event is published' do
      subscriber = double('Subscriber')
      allow(subscriber).to receive(:call).with(payment_event)

      event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, subscriber)
      event_publisher.publish(payment_event)

      expect(subscriber).to have_received(:call).with(payment_event)
    end

    it 'does not notify subscribers of different event types' do
      subscriber = double('Subscriber')
      allow(subscriber).to receive(:call)

      event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, subscriber)
      event_publisher.publish(subscription_event)

      expect(subscriber).not_to have_received(:call)
    end

    it 'handles errors raised by subscribers' do
      subscriber = double('Subscriber')
      allow(subscriber).to receive(:call).and_raise('Something went wrong')

      event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, subscriber)

      expect { event_publisher.publish(payment_event) }.not_to raise_error
    end
  end

  describe '#clear_subscribers' do
    it 'removes all subscribers' do
      subscriber = double('Subscriber', call: nil)
      event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, subscriber)
      event_publisher.clear_subscribers

      expect { event_publisher.publish(payment_event) }.not_to raise_error
    end
  end
end
