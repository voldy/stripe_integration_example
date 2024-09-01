module Billing
  module Services
    # The SubscriptionService class encapsulates the business logic associated with managing subscriptions
    # within the billing domain. It provides methods to create subscriptions, mark them as paid, and cancel
    # them, while also publishing relevant domain events when these actions are performed.
    #
    # The service uses a repository to persist and retrieve subscription entities, and an event publisher
    # to broadcast domain events that notify the rest of the system about significant changes to subscriptions.
    class SubscriptionService
      # Initializes the SubscriptionService with a repository and an optional event publisher.
      #
      # @param repository [Billing::Repositories::SubscriptionRepository] The repository used to persist and retrieve subscriptions.
      # @param event_publisher [Billing::EventPublisher] The event publisher used to publish domain events.
      def initialize(repository, event_publisher = Billing::EventPublisher.instance)
        @repository = repository
        @event_publisher = event_publisher
      end

      # Creates a new subscription, saves it to the repository, and publishes a SubscriptionCreatedEvent.
      #
      # @param attributes [Hash] The attributes required to create a new subscription. Expected keys are :id and :customer_id.
      # @return [Billing::Entities::Subscription] The created subscription entity.
      #
      # Example usage:
      #   attributes = { id: 'sub_123', customer_id: 'cus_123' }
      #   subscription_service.create_subscription(attributes)
      def create_subscription(attributes)
        subscription = Billing::Entities::Subscription.new(
          id: attributes[:id],
          customer_id: attributes[:customer_id],
          status: 'unpaid'  # Status is explicitly set to 'unpaid'
        )
        @repository.save(subscription)

        @event_publisher.publish(Billing::Events::SubscriptionCreatedEvent.new(
          subscription_id: subscription.id,
          customer_id: subscription.customer_id,
          status: subscription.status
        ))

        Result.success(subscription)
      end

      # Marks a subscription as paid, saves the updated subscription, and publishes a PaymentSucceededEvent if successful.
      #
      # This method retrieves the subscription by its ID, validates whether it can be marked as paid,
      # and if successful, updates its status to "paid". It then saves the updated subscription and
      # publishes an event indicating that the payment was successful.
      #
      # @param subscription_id [String] The ID of the subscription to mark as paid.
      # @return [Result] A Result object indicating the success or failure of the operation.
      #
      # Example usage:
      #   result = subscription_service.mark_subscription_as_paid('sub_123')
      #   if result.success?
      #     puts "Subscription marked as paid"
      #   else
      #     puts "Failed to mark as paid: #{result.error_message}"
      #   end
      def mark_subscription_as_paid(subscription_id)
        subscription = @repository.find_by_id(subscription_id)
        return Result.failure("Subscription not found") unless subscription

        result = subscription.mark_as_paid
        if result.success?
          @repository.save(subscription)
          @event_publisher.publish(Billing::Events::PaymentSucceededEvent.new(
            subscription_id: subscription.id,
            customer_id: subscription.customer_id
          ))
        end

        result
      end

      # Cancels a subscription, saves the updated subscription, and publishes a SubscriptionCanceledEvent if successful.
      #
      # This method retrieves the subscription by its ID, validates whether it can be canceled,
      # and if successful, updates its status to "canceled". It then saves the updated subscription and
      # publishes an event indicating that the subscription was canceled.
      #
      # @param subscription_id [String] The ID of the subscription to cancel.
      # @return [Result] A Result object indicating the success or failure of the operation.
      #
      # Example usage:
      #   result = subscription_service.cancel_subscription('sub_123')
      #   if result.success?
      #     puts "Subscription canceled"
      #   else
      #     puts "Failed to cancel subscription: #{result.error_message}"
      #   end
      def cancel_subscription(subscription_id)
        subscription = @repository.find_by_id(subscription_id)
        return Result.failure("Subscription not found") unless subscription

        result = subscription.cancel
        if result.success?
          @repository.save(subscription)
          @event_publisher.publish(Billing::Events::SubscriptionCanceledEvent.new(
            subscription_id: subscription.id,
            customer_id: subscription.customer_id,
            status: subscription.status
          ))
        end

        result
      end
    end
  end
end
