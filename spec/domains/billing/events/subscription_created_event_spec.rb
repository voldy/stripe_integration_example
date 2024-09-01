require 'rails_helper'

RSpec.describe Billing::Events::SubscriptionCreatedEvent, type: :model do
  let(:subscription_id) { 'sub_123' }
  let(:customer_id) { 'cus_123' }
  let(:status) { 'active' }
  let(:timestamp) { Time.now }
  let(:uuid) { SecureRandom.uuid }
  let(:event) do
    described_class.new(
      subscription_id: subscription_id,
      customer_id: customer_id,
      status: status,
      version: "1.0",
      timestamp: timestamp,
      id: uuid
    )
  end

  describe '#initialize' do
    it 'assigns the UUID correctly' do
      expect(event.id).to eq(uuid)
    end

    it 'assigns the payload correctly' do
      expect(event.payload).to eq({
        subscription_id: subscription_id,
        customer_id: customer_id,
        status: status
      })
    end

    it 'assigns the version correctly' do
      expect(event.version).to eq("1.0")
    end

    it 'assigns the timestamp correctly' do
      expect(event.timestamp).to eq(timestamp)
    end
  end

  describe '#to_s' do
    it 'returns a string representation of the event' do
      expect(event.to_s).to eq("SubscriptionCreatedEvent: #{event.payload}, version: 1.0, timestamp: #{timestamp}, id: #{uuid}")
    end
  end
end
