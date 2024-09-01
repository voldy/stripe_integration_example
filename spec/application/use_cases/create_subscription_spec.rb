require 'rails_helper'

RSpec.describe UseCases::CreateSubscription, type: :use_case do
  let(:subscription_service) { instance_double(Billing::Services::SubscriptionService) }
  let(:use_case) { described_class.new(subscription_service) }

  describe '#call' do
    let(:data) { { 'id' => 'sub_123', 'customer' => 'cus_123', 'status' => 'active' } }

    it 'calls the SubscriptionService to create a subscription' do
      expect(subscription_service).to receive(:create_subscription).with(id: 'sub_123', customer_id: 'cus_123')
      use_case.call(data)
    end
  end
end
