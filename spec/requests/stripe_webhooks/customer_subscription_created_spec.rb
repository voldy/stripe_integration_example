require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe 'Stripe Webhooks', type: :request do
  describe 'POST /stripe_webhooks for customer.subscription.created' do
    let(:payload) { File.read(Rails.root.join('spec/support/stripe_webhooks/customer_subscription_created.json')) }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

    before do
      allow(StripeWebhookVerifier).to receive(:verify!).and_return(JSON.parse(payload))
    end

    it 'creates a new subscription' do
      expect {
        perform_enqueued_jobs do
          post '/stripe_webhooks', params: payload, headers: headers
        end
      }.to change { Subscription.count }.by(1)

      expect(response).to have_http_status(:ok)

      subscription = Subscription.last
      expect(subscription.id).to eq('sub_1PuAS71ys6gw4QBOkuHPkBQm')  
      expect(subscription.customer_id).to eq('cus_QkIVyFJekJMYbR')  
      expect(subscription.status).to eq('unpaid')  
    end
  end
end
