require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe 'Stripe Webhooks', type: :request do
  describe 'POST /stripe_webhooks for invoice.payment_succeeded' do
    let(:subscription_id) { 'sub_1PuAS71ys6gw4QBOkuHPkBQm' }
    let(:payload) { File.read(Rails.root.join('spec/support/stripe_webhooks/invoice_payment_succeeded.json')) }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    before do
      allow(StripeWebhookVerifier).to receive(:verify!).and_return(JSON.parse(payload))
      clear_enqueued_jobs
      clear_performed_jobs
    end

    context 'when the subscription exists' do
      before do
        Subscription.create(id: subscription_id, customer_id: 'cus_123', status: 'unpaid')
      end

      it 'marks the subscription as paid' do
        expect {
          perform_enqueued_jobs do
            post '/stripe_webhooks', params: payload, headers: headers
          end
        }.to change { Subscription.find(subscription_id).status }.from('unpaid').to('paid')

        expect(response).to have_http_status(:ok)

        subscription = Subscription.find(subscription_id)
        expect(subscription.status).to eq('paid')
      end
    end

    context 'when the subscription does not exist' do
      it 'reschedules the job and fails if subscription is not created before the last attempt' do
        expect {
          perform_enqueued_jobs do
            post '/stripe_webhooks', params: payload, headers: headers
          end
        }.not_to change { Subscription.count }

        expect(response).to have_http_status(:ok)

        assert_performed_jobs 5  # 5 attempts 

        stripe_event = StripeEvent.find_by(event_id: JSON.parse(payload)['id'])
        expect(stripe_event.reload.status).to eq('failed')
      end
    end

    context 'when out-of-order events' do
      let(:subscription_payload) { File.read(Rails.root.join('spec/support/stripe_webhooks/customer_subscription_created.json')) }

      before do
        allow(StripeWebhookVerifier).to receive(:verify!).and_return(JSON.parse(payload), JSON.parse(subscription_payload))
      end

      it 'reschedules the job and marks the subscription as paid if it was created meantime' do
        post '/stripe_webhooks', params: payload, headers: headers
        post '/stripe_webhooks', params: subscription_payload, headers: headers

        expect { perform_enqueued_jobs }.to change { Subscription.count }
        assert_performed_jobs 2   

        subscription = Subscription.last
        expect(subscription.status).to eq('unpaid')  

        stripe_event = StripeEvent.find_by(event_id: JSON.parse(payload)['id'])
        expect(stripe_event.reload.status).to eq('pending')

        expect { perform_enqueued_jobs }.to change { 
          Subscription.find(subscription_id).status }.from('unpaid').to('paid')

        stripe_event.reload
        expect(stripe_event.reload.status).to eq('processed')
      end
    end    
  end
end
