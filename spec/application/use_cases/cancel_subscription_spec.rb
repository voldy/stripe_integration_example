require 'rails_helper'

RSpec.describe UseCases::CancelSubscription, type: :use_case do
  let(:subscription_service) { instance_double(Billing::Services::SubscriptionService) }
  let(:use_case) { described_class.new(subscription_service) }

  describe '#call' do
    it 'calls the SubscriptionService to cancel the subscription' do
      expect(subscription_service).to receive(:cancel_subscription).with('sub_123')
      use_case.call('sub_123')
    end
  end
end
