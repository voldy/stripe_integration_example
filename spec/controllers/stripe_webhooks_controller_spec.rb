require 'rails_helper'

RSpec.describe StripeWebhooksController, type: :controller do
  describe 'POST #handle' do
    let(:event) { { 'id' => 'evt_test', 'type' => 'payment_intent.succeeded', 'data' => { 'object' => {} } } }
    let(:request_body) { event.to_json }
    let(:signature_header) { 'valid_signature' } 

    before do
      request.headers['HTTP_STRIPE_SIGNATURE'] = signature_header
      allow(StripeWebhookVerifier).to receive(:verify!).and_return(event)
      allow(Handlers::StripeWebhookHandler).to receive(:process)
    end

    context 'with a valid signature' do
      it 'returns a success response' do
        post :handle, body: request_body
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ message: 'success' }.to_json)
      end
    end

    context 'with an invalid signature' do
      before do
        allow(StripeWebhookVerifier).to receive(:verify!).and_raise(StripeWebhookVerifier::InvalidSignatureError.new('Invalid signature'))
      end

      it 'returns a 400 error' do
        post :handle, body: request_body
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({ error: 'Invalid signature' }.to_json)
      end
    end

    context 'when an exception is raised during processing' do
      before do
        allow(Handlers::StripeWebhookHandler).to receive(:process).and_raise(StandardError.new('Something went wrong'))
      end

      it 'returns a 500 error' do
        post :handle, body: request_body
        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to eq({ error: 'Something went wrong' }.to_json)
      end
    end
  end
end
