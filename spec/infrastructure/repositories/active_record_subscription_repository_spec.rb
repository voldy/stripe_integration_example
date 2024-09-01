require 'rails_helper'

RSpec.describe Repositories::ActiveRecordSubscriptionRepository, type: :repository do
  let(:repository) { described_class.new }

  describe '#save' do
    it 'saves a subscription to the database' do
      subscription = Billing::Entities::Subscription.new(
        id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p',
        customer_id: 'cus_QkIVyFJekJMYbR',
        status: 'unpaid'
      )

      repository.save(subscription)
      record = Subscription.find_by(id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p')

      expect(record).not_to be_nil
      expect(record.customer_id).to eq('cus_QkIVyFJekJMYbR')
      expect(record.status).to eq('unpaid')
    end

    it 'updates an existing subscription in the database' do
      existing_subscription = Subscription.create!(
        id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p',
        customer_id: 'cus_QkIVyFJekJMYbR',
        status: 'unpaid'
      )

      updated_subscription = Billing::Entities::Subscription.new(
        id: existing_subscription.id,
        customer_id: 'cus_QkIVyFJekJMYbR',
        status: 'paid'
      )

      repository.save(updated_subscription)
      record = Subscription.find_by(id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p')

      expect(record).not_to be_nil
      expect(record.status).to eq('paid')
    end
  end

  describe '#find_by_id' do
    it 'finds a subscription by id' do
      Subscription.create!(
        id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p',
        customer_id: 'cus_QkIVyFJekJMYbR',
        status: 'unpaid'
      )

      subscription = repository.find_by_id('sub_1Psnvp1ys6gw4QBOoQ9q3v3p')

      expect(subscription).not_to be_nil
      expect(subscription.id).to eq('sub_1Psnvp1ys6gw4QBOoQ9q3v3p')
      expect(subscription.customer_id).to eq('cus_QkIVyFJekJMYbR')
      expect(subscription.status).to eq('unpaid')
    end

    it 'returns nil if subscription is not found' do
      subscription = repository.find_by_id('non_existent_id')

      expect(subscription).to be_nil
    end
  end
end
