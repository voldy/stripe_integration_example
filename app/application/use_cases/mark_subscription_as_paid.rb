module UseCases
  # The MarkSubscriptionAsPaid use case is responsible for marking an existing subscription as paid.
  class MarkSubscriptionAsPaid < BaseUseCase
    # Executes the use case to mark a subscription as paid.
    #
    # @param subscription_id [String] The ID of the subscription to be marked as paid.
    # @return [Result] A Result object indicating the success or failure of the operation.
    def call(subscription_id)
      subscription_service.mark_subscription_as_paid(subscription_id)
    end    
  end
end
