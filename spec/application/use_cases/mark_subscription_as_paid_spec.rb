require 'rails_helper'

RSpec.describe UseCases::MarkSubscriptionAsPaid, type: :use_case do
  let(:subscription_service) { instance_double(Billing::Services::SubscriptionService) }
  let(:use_case) { described_class.new(subscription_service) }

  describe '#call' do
    it 'calls the SubscriptionService to mark the subscription as paid' do
      expect(subscription_service).to receive(:mark_subscription_as_paid).with('sub_123')
      use_case.call('sub_123')
    end
  end
end
