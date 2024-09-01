# app/domains/billing/events/subscription_canceled_event.rb
require 'securerandom'

module Billing
  module Events
    # The SubscriptionCanceledEvent class represents the event that occurs when a subscription
    # is canceled. It includes metadata like UUID, timestamp, and version.
    class SubscriptionCanceledEvent
      attr_reader :id, :payload, :timestamp, :version

      # Initializes the SubscriptionCanceledEvent.
      #
      # @param subscription_id [String] The ID of the subscription.
      # @param customer_id [String] The ID of the customer associated with the subscription.
      # @param status [String] The status of the subscription at the time of cancellation.
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
        "SubscriptionCanceledEvent: #{payload}, version: #{@version}, timestamp: #{@timestamp}, id: #{@id}"
      end
    end
  end
end
