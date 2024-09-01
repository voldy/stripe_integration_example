module Repositories
  # The ActiveRecordSubscriptionRepository class implements the SubscriptionRepository interface
  # using ActiveRecord to interact with the database. It provides methods to persist and find
  # Subscription entities using the Subscription ActiveRecord model.
  class ActiveRecordSubscriptionRepository < Billing::Repositories::SubscriptionRepository
    # Persists a subscription entity by either creating a new record or updating an existing one.
    #
    # @param subscription [Billing::Entities::Subscription] The subscription entity to save.
    # @return [void]
    def save(subscription)
      subscription_record = ::Subscription.find_or_initialize_by(id: subscription.id)
      subscription_record.update!(
        customer_id: subscription.customer_id,
        status: subscription.status
      )
    end

    # Finds a subscription by its ID.
    #
    # @param id [String] The ID of the subscription.
    # @return [Billing::Entities::Subscription, nil] The subscription entity if found, otherwise nil.
    def find_by_id(id)
      subscription_record = ::Subscription.find_by(id: id)
      return unless subscription_record

      Billing::Entities::Subscription.new(
        id: subscription_record.id,
        customer_id: subscription_record.customer_id,
        status: subscription_record.status
      )
    end
  end
end
