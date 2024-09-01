module UseCases
  # The BaseUseCase class serves as a foundation for other use cases within the application.
  # It provides a common initialization method that sets up the SubscriptionService, which is used
  # to handle subscription-related business logic across multiple use cases.
  #
  # Use cases inheriting from this class can easily access the subscription_service instance variable
  # to perform operations related to subscriptions.
  class BaseUseCase
    attr_reader :subscription_service

    # Initializes the BaseUseCase with a SubscriptionService.
    #
    # @param subscription_service [Billing::Services::SubscriptionService] The service used to manage subscription logic.
    def initialize(subscription_service = Billing::Services::SubscriptionService.new(
        Repositories::ActiveRecordSubscriptionRepository.new))
      @subscription_service = subscription_service
    end
  end
end
