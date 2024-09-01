require 'rails_helper'

RSpec.describe Billing::Entities::Subscription, type: :model do
  let(:validator) { instance_double(Billing::Validators::SubscriptionValidator) }
  let(:subscription) { described_class.new(id: 'sub_123', customer_id: 'cus_123', status: status, validator: validator) }

  describe '#mark_as_paid' do
    context 'when the subscription is unpaid' do
      let(:status) { 'unpaid' }

      it 'marks the subscription as paid' do
        allow(validator).to receive(:valid_for_payment?).with(subscription).and_return(true)

        result = subscription.mark_as_paid

        expect(result).to be_success
        expect(subscription.status).to eq('paid')
      end
    end

    context 'when the subscription is already paid' do
      let(:status) { 'paid' }

      it 'returns a failure result' do
        allow(validator).to receive(:valid_for_payment?).with(subscription).and_return(false)
        allow(validator).to receive(:errors).and_return(["Subscription is already paid"])

        result = subscription.mark_as_paid

        expect(result).to be_failure
        expect(result.error).to eq('Subscription is already paid')
      end
    end

    context 'when the subscription is canceled' do
      let(:status) { 'canceled' }

      it 'returns a failure result' do
        allow(validator).to receive(:valid_for_payment?).with(subscription).and_return(false)
        allow(validator).to receive(:errors).and_return(["Cannot pay for a canceled subscription"])

        result = subscription.mark_as_paid

        expect(result).to be_failure
        expect(result.error).to eq('Cannot pay for a canceled subscription')
      end
    end
  end

  describe '#cancel' do
    context 'when the subscription is paid' do
      let(:status) { 'paid' }

      it 'cancels the subscription' do
        allow(validator).to receive(:valid_for_cancellation?).with(subscription).and_return(true)

        result = subscription.cancel

        expect(result).to be_success
        expect(subscription.status).to eq('canceled')
      end
    end

    context 'when the subscription is unpaid' do
      let(:status) { 'unpaid' }

      it 'returns a failure result' do
        allow(validator).to receive(:valid_for_cancellation?).with(subscription).and_return(false)
        allow(validator).to receive(:errors).and_return(["Only paid subscriptions can be canceled"])

        result = subscription.cancel

        expect(result).to be_failure
        expect(result.error).to eq('Only paid subscriptions can be canceled')
      end
    end

    context 'when the subscription is already canceled' do
      let(:status) { 'canceled' }

      it 'returns a failure result' do
        allow(validator).to receive(:valid_for_cancellation?).with(subscription).and_return(false)
        allow(validator).to receive(:errors).and_return(["Only paid subscriptions can be canceled"])

        result = subscription.cancel

        expect(result).to be_failure
        expect(result.error).to eq('Only paid subscriptions can be canceled')
      end
    end
  end
end
