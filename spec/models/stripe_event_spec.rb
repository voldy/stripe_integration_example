require 'rails_helper'

RSpec.describe StripeEvent, type: :model do
  describe 'validations' do
    it 'validates presence of event_id' do
      event = StripeEvent.new(event_id: nil)
      event.validate
      expect(event.errors[:event_id]).to include("can't be blank")
    end

    it 'validates presence of event_type' do
      event = StripeEvent.new(event_type: nil)
      event.validate
      expect(event.errors[:event_type]).to include("can't be blank")
    end

    it 'validates presence of payload' do
      event = StripeEvent.new(payload: nil)
      event.validate
      expect(event.errors[:payload]).to include("can't be blank")
    end

    it 'validates uniqueness of event_id' do
      existing_event = StripeEvent.create!(
        event_id: 'evt_test', 
        event_type: 'payment_intent.succeeded', 
        payload: { 'data' => 'test' }
      )
      new_event = StripeEvent.new(
        event_id: 'evt_test',
        event_type: 'payment_intent.succeeded',
        payload: { 'data' => 'test' }
      )
      new_event.validate
      expect(new_event.errors[:event_id]).to include('has already been taken')
    end

    it 'validates inclusion of status' do
      event = StripeEvent.new(status: 'invalid_status')
      event.validate
      expect(event.errors[:status]).to include('invalid_status is not a valid status')
    end

    it 'allows valid statuses' do
      valid_statuses = %w[pending processed unhandled failed]
      valid_statuses.each do |status|
        event = StripeEvent.new(status: status)
        event.validate
        expect(event.errors[:status]).to be_empty
      end
    end
  end
end
