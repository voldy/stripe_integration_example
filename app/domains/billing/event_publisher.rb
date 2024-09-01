module Billing
  # The EventPublisher class is responsible for managing the publishing of domain events to registered subscribers.
  # It uses the Singleton design pattern, ensuring that only one instance of the publisher exists within the application.
  #
  # This class allows different parts of the system to subscribe to specific event types and ensures that when an event
  # is published, all relevant subscribers are notified. It handles errors gracefully during event delivery, logging them
  # without disrupting the event flow.
  #
  # Usage example:
  #   class PaymentEventHandler
  #     def self.call(event)
  #       # Handle the event
  #       puts "Payment succeeded for subscription #{event.payload[:subscription_id]}"
  #     end
  #   end
  #
  #   event_publisher = Billing::EventPublisher.instance
  #   event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, PaymentEventHandler)
  #
  #   event = Billing::Events::PaymentSucceededEvent.new(subscription_id: 'sub_123', customer_id: 'cus_123')
  #   event_publisher.publish(event)
  #
  #   # Output: "Payment succeeded for subscription sub_123"
  class EventPublisher
    include Singleton

    def initialize
      @subscribers = {}
    end

    # Registers a subscriber for a specific event type.
    #
    # @param event_class [Class] The event class the subscriber is interested in.
    # @param subscriber [Object] The subscriber, which should respond to a `call` method.
    def subscribe(event_class, subscriber)
      @subscribers[event_class] ||= []
      @subscribers[event_class] << subscriber
    end

    # Publishes an event to all registered subscribers.
    #
    # @param event [Object] The event object to publish.
    def publish(event)
      event_class = event.class
      if @subscribers[event_class]
        @subscribers[event_class].each do |subscriber|
          begin
            subscriber.call(event)
          rescue => e
            Rails.logger.error "Error delivering event: #{e.message}"
          end
        end
      end
    end

    # Clears all subscribers (useful for testing).
    def clear_subscribers
      @subscribers.clear
    end
  end
end
