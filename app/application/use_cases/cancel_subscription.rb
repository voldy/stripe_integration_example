module UseCases
  # The CancelSubscription use case is responsible for canceling an existing subscription.
  class CancelSubscription < BaseUseCase
    # Executes the use case to cancel a subscription.
    #
    # @param subscription_id [String] The ID of the subscription to be canceled.
    # @return [Result] A Result object indicating the success or failure of the operation.
    def call(subscription_id)
      subscription_service.cancel_subscription(subscription_id)
    end
  end
end
