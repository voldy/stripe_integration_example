module Billing
  module Repositories
    # The SubscriptionRepository class serves as an abstract base class for managing subscriptions in the billing domain.
    # It defines the essential operations for interacting with subscription entities, including finding adn saving.
    # Concrete subclasses are expected to implement these methods using specific data storage mechanisms (e.g., ActiveRecord, in-memory storage, etc.).
    #
    # This design follows the repository pattern, which abstracts the data persistence logic from the business logic,
    # allowing for more flexible and testable code. By defining these methods in an abstract class, we ensure that any
    # subclass provides consistent behavior for managing subscription entities.
    #
    class SubscriptionRepository
      # Finds a subscription by its ID.
      #
      # @param id [String] The ID of the subscription.
      # @return [Billing::Entities::Subscription, nil] The subscription if found, otherwise nil.
      # @raise [NotImplementedError] if the method is not implemented in a subclass.
      def find_by_id(id)
        raise NotImplementedError, "find_by_id must be implemented in a subclass"
      end

      # Persists a subscription.
      #
      # @param subscription [Billing::Entities::Subscription] The subscription entity to save.
      # @return [void]
      # @raise [NotImplementedError] if the method is not implemented in a subclass.
      def save(subscription)
        raise NotImplementedError, "save must be implemented in a subclass"
      end
    end
  end
end
