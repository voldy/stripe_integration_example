# spec/lib/stripe_webhook_verifier_spec.rb

require 'rails_helper'

RSpec.describe StripeWebhookVerifier do
  let(:request) { instance_double(ActionDispatch::Request) }
  let(:payload) { '{ "id": "evt_test", "object": "event" }' }
  let(:sig_header) { 't=12345,v1=signature' }
  let(:endpoint_secret) { 'whsec_test_secret' }

  before do
    allow(request).to receive(:body).and_return(StringIO.new(payload))
    allow(request).to receive(:env).and_return({ 'HTTP_STRIPE_SIGNATURE' => sig_header })
    allow(ENV).to receive(:[]).with('STRIPE_ENDPOINT_SECRET').and_return(endpoint_secret)
  end

  describe '.verify!' do
    context 'when the payload is valid and the signature is correct' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(double('Stripe::Event'))
      end

      it 'does not raise an error' do
        expect {
          StripeWebhookVerifier.verify!(request)
        }.not_to raise_error
      end
    end

    context 'when the payload is invalid' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError.new('Unexpected token'))
      end

      it 'raises an InvalidPayloadError' do
        expect {
          StripeWebhookVerifier.verify!(request)
        }.to raise_error(StripeWebhookVerifier::InvalidPayloadError, 'Invalid payload: Unexpected token')
      end
    end

    context 'when the signature is invalid' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(Stripe::SignatureVerificationError.new('Invalid signature', sig_header))
      end

      it 'raises an InvalidSignatureError' do
        expect {
          StripeWebhookVerifier.verify!(request)
        }.to raise_error(StripeWebhookVerifier::InvalidSignatureError, 'Invalid signature: Invalid signature')
      end
    end
  end
end
