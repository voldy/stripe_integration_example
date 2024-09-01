require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe 'Stripe Webhooks', type: :request do
  describe 'POST /stripe_webhooks for customer.subscription.deleted' do
    let(:subscription_id) { 'sub_1PuAS71ys6gw4QBOkuHPkBQm' }
    let(:payload) { File.read(Rails.root.join('spec/support/stripe_webhooks/customer_subscription_deleted.json')) }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    before do
      allow(StripeWebhookVerifier).to receive(:verify!).and_return(JSON.parse(payload))
      clear_enqueued_jobs
      clear_performed_jobs
    end

    context 'when the subscription exists and is paid' do
      before do
        Subscription.create(id: subscription_id, customer_id: 'cus_123', status: 'paid')
      end

      it 'cancels the subscription and updates the StripeEvent status to processed' do
        expect {
          perform_enqueued_jobs do
            post '/stripe_webhooks', params: payload, headers: headers
          end
        }.to change { Subscription.find(subscription_id).status }.from('paid').to('canceled')

        expect(response).to have_http_status(:ok)

        subscription = Subscription.find(subscription_id)
        expect(subscription.status).to eq('canceled')

        stripe_event = StripeEvent.find_by(event_id: JSON.parse(payload)['id'])
        expect(stripe_event).not_to be_nil
        expect(stripe_event.status).to eq('processed')
      end
    end

    context 'when the subscription exists and is unpaid' do
      before do
        Subscription.create(id: subscription_id, customer_id: 'cus_123', status: 'unpaid')
      end

      it 'does not cancel the subscription and marks the StripeEvent as failed' do
        expect {
          perform_enqueued_jobs do
            post '/stripe_webhooks', params: payload, headers: headers
          end
        }.not_to change { Subscription.find(subscription_id).status }

        expect(response).to have_http_status(:ok)

        subscription = Subscription.find(subscription_id)
        expect(subscription.status).to eq('unpaid')

        stripe_event = StripeEvent.find_by(event_id: JSON.parse(payload)['id'])
        expect(stripe_event).not_to be_nil
        expect(stripe_event.status).to eq('failed')
      end
    end

    context 'when the subscription does not exist' do
      it 'creates a failed StripeEvent and does not change Subscription count' do
        expect {
          perform_enqueued_jobs do
            post '/stripe_webhooks', params: payload, headers: headers
          end
        }.not_to change { Subscription.count }

        expect(response).to have_http_status(:ok)

        stripe_event = StripeEvent.find_by(event_id: JSON.parse(payload)['id'])
        expect(stripe_event).not_to be_nil
        expect(stripe_event.status).to eq('failed')
      end
    end
  end
end
