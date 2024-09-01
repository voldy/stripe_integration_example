module UseCases
  # The CreateSubscription use case is responsible for handling the creation of a new subscription.
  class CreateSubscription < BaseUseCase
    # Executes the use case to create a new subscription.
    #
    # @param data [Hash] The data required to create the subscription, including :id, :customer, and :status.
    # @return [Billing::Entities::Subscription] The created subscription entity.
    def call(data)
      subscription_service.create_subscription(
        id: data['id'],
        customer_id: data['customer']
      )
    end
  end
end
