require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it 'is valid with valid attributes' do
    subscription = Subscription.new(id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p', customer_id: 'cus_QkIVyFJekJMYbR', status: 'canceled')
    expect(subscription).to be_valid
  end

  it 'is invalid without a customer_id' do
    subscription = Subscription.new(id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p', customer_id: nil, status: 'canceled')
    expect(subscription).not_to be_valid
  end

  it 'is invalid without a status' do
    subscription = Subscription.new(id: 'sub_1Psnvp1ys6gw4QBOoQ9q3v3p', customer_id: 'cus_QkIVyFJekJMYbR', status: nil)
    expect(subscription).not_to be_valid
  end

  it 'validates inclusion of status' do
    event = Subscription.new(status: 'invalid_status')
    event.validate
    expect(event.errors[:status]).to include('invalid_status is not a valid status')
  end

  it 'allows valid statuses' do
    valid_statuses = %w[unpaid paid canceled]
    valid_statuses.each do |status|
      event = Subscription.new(status: status)
      event.validate
      expect(event.errors[:status]).to be_empty
    end
  end
end
