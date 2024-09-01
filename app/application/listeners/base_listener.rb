module Listeners
  # The BaseListener class serves as an abstract base class for all event listeners.
  # It enforces the implementation of the `call` method in all subclasses.
  class BaseListener
    # Handles the domain event.
    #
    # @param event [Object] The event object that was published.
    # @abstract Subclasses must implement the `call` method.
    def self.call(event)
      raise NotImplementedError, "#{self.class} must implement the call method"
    end
  end
end
