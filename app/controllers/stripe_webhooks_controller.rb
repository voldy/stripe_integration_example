class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_stripe_request

  def handle
    Handlers::StripeWebhookHandler.process(@stripe_event)
    render json: { message: 'success' }, status: 200
  rescue => e
    render json: { error: e.message }, status: 500
  end

  private

  def verify_stripe_request
    @stripe_event = StripeWebhookVerifier.verify!(request)
  rescue StripeWebhookVerifier::InvalidPayloadError, StripeWebhookVerifier::InvalidSignatureError => e
    render json: { error: e.message }, status: 400
  end
end
