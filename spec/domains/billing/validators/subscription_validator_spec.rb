require 'rails_helper'

RSpec.describe Billing::Validators::SubscriptionValidator, type: :model do
  let(:validator) { described_class.new }
  let(:subscription) { instance_double('Subscription', status: status) }

  describe '#valid_for_payment?' do
    context 'when the subscription is unpaid' do
      let(:status) { 'unpaid' }

      it 'returns true and has no errors' do
        result = validator.valid_for_payment?(subscription)

        expect(result).to be true
        expect(validator.errors).to be_empty
      end
    end

    context 'when the subscription is already paid' do
      let(:status) { 'paid' }

      it 'returns false and adds an error' do
        result = validator.valid_for_payment?(subscription)

        expect(result).to be false
        expect(validator.errors).to include("Subscription is already paid")
      end
    end

    context 'when the subscription is canceled' do
      let(:status) { 'canceled' }

      it 'returns false and adds an error' do
        result = validator.valid_for_payment?(subscription)

        expect(result).to be false
        expect(validator.errors).to include("Cannot pay for a canceled subscription")
      end
    end
  end

  describe '#valid_for_cancellation?' do
    context 'when the subscription is paid' do
      let(:status) { 'paid' }

      it 'returns true and has no errors' do
        result = validator.valid_for_cancellation?(subscription)

        expect(result).to be true
        expect(validator.errors).to be_empty
      end
    end

    context 'when the subscription is unpaid' do
      let(:status) { 'unpaid' }

      it 'returns false and adds an error' do
        result = validator.valid_for_cancellation?(subscription)

        expect(result).to be false
        expect(validator.errors).to include("Only paid subscriptions can be canceled")
      end
    end

    context 'when the subscription is already canceled' do
      let(:status) { 'canceled' }

      it 'returns false and adds an error' do
        result = validator.valid_for_cancellation?(subscription)

        expect(result).to be false
        expect(validator.errors).to include("Only paid subscriptions can be canceled")
      end
    end
  end
end
