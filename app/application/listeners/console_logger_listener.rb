module Listeners
  # ConsoleLoggerListener listens for domain events and logs them to the Rails console.
  class ConsoleLoggerListener < BaseListener
    # Handles the domain event by logging it to the Rails console with info status.
    #
    # @param event [Object] The event object that was published.
    def self.call(event)
      Rails.logger.info "Event published: #{event.class.name}, Payload: #{event.to_s}"
    end
  end
end
