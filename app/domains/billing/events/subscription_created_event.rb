# app/domains/billing/events/subscription_created_event.rb

module Billing
  module Events
    class SubscriptionCreatedEvent
      attr_reader :id, :payload, :version, :timestamp

      # Initializes the SubscriptionCreatedEvent.
      #
      # @param subscription_id [String] The ID of the subscription.
      # @param customer_id [String] The ID of the customer associated with the subscription.
      # @param status [String] The status of the subscription when it was created.
      # @param version [String] The version of the event format (default: "1.0").
      # @param timestamp [Time] The time when the event occurred (default: current time).
      # @param id [String] The unique identifier for this event (default: generated UUID).
      def initialize(subscription_id:, customer_id:, status:, version: "1.0", timestamp: Time.now, id: SecureRandom.uuid)
        @id = id
        @payload = {
          subscription_id: subscription_id,
          customer_id: customer_id,
          status: status
        }
        @version = version
        @timestamp = timestamp
      end

      # Returns a string representation of the event.
      #
      # @return [String] A string describing the event.
      def to_s
        "SubscriptionCreatedEvent: #{payload}, version: #{@version}, timestamp: #{@timestamp}, id: #{@id}"
      end
    end
  end
end
