# lib/stripe_webhook_verifier.rb

# StripeWebhookVerifier is responsible for verifying the authenticity of incoming
# Stripe webhook requests. It ensures that the payload and signature sent by Stripe
# match the expected values using the endpoint's secret key.
#
# Example usage:
#   event = StripeWebhookVerifier.verify!(request)
#
# If the verification fails due to an invalid payload or signature, an appropriate
# error is raised.
module StripeWebhookVerifier
  # Raised when the payload of the webhook request cannot be parsed.
  class InvalidPayloadError < StandardError; end

  # Raised when the signature verification fails, indicating that the request may not
  # have come from Stripe or has been tampered with.
  class InvalidSignatureError < StandardError; end

  # Verifies the Stripe webhook request by checking the payload and signature.
  #
  # @param request [ActionDispatch::Request] The incoming HTTP request object.
  # @return [Stripe::Event] The verified Stripe event.
  # @raise [InvalidPayloadError] If the request payload is invalid and cannot be parsed.
  # @raise [InvalidSignatureError] If the signature verification fails.
  def self.verify!(request)
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_ENDPOINT_SECRET']

    begin
      Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      raise InvalidPayloadError, "Invalid payload: #{e.message}"
    rescue Stripe::SignatureVerificationError => e
      raise InvalidSignatureError, "Invalid signature: #{e.message}"
    end
  end
end
