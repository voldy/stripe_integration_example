require 'rails_helper'

RSpec.describe Listeners::ConsoleLoggerListener, type: :listener do
  let(:event) { Billing::Events::SubscriptionCreatedEvent.new(
    subscription_id: 'sub_123', customer_id: 'cus_123', status: 'unpaid') }

  it 'logs the event to the Rails console with info status' do
    expect(Rails.logger).to receive(:info).with(
      "Event published: #{event.class.name}, Payload: #{event.to_s}")

    described_class.call(event)
  end
end
