# app/domains/billing/events/payment_succeeded_event.rb
require 'securerandom'

module Billing
  module Events
    # The PaymentSucceededEvent class represents the event that occurs when a payment
    # for a subscription succeeds. It includes metadata like UUID, timestamp, and version.
    class PaymentSucceededEvent
      attr_reader :id, :payload, :timestamp, :version

      # Initializes the PaymentSucceededEvent.
      #
      # @param subscription_id [String] The ID of the subscription.
      # @param customer_id [String] The ID of the customer associated with the subscription.
      # @param version [String] The version of the event format (default: "1.0").
      # @param timestamp [Time] The time when the event occurred (default: current time).
      # @param id [String] The unique identifier for this event (default: generated UUID).
      def initialize(subscription_id:, customer_id:, version: "1.0", timestamp: Time.now, id: SecureRandom.uuid)
        @id = id
        @payload = {
          subscription_id: subscription_id,
          customer_id: customer_id,
        }
        @version = version
        @timestamp = timestamp
      end

      # Returns a string representation of the event.
      #
      # @return [String] A string describing the event.
      def to_s
        "PaymentSucceededEvent: #{payload}, version: #{@version}, timestamp: #{@timestamp}, id: #{@id}"
      end
    end
  end
end
