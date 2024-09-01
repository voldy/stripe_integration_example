# app/domains/billing/validators/subscription_validator.rb

module Billing::Validators
  # The SubscriptionValidator class is responsible for validating the state
  # of a Subscription entity before performing certain operations.
  # It encapsulates the business rules related to the Subscription's state,
  # ensuring that operations like payment and cancellation are only performed
  # when the Subscription is in a valid state.
  #
  class SubscriptionValidator
    attr_reader :errors

    # Initializes a new SubscriptionValidator.
    def initialize
      @errors = []
    end

    # Validates whether the Subscription is in a valid state for payment.
    #
    # @param subscription [Billing::Entity::Subscription] The subscription entity to be validated.
    # @return [Boolean] Returns true if the Subscription is valid for payment, false otherwise.
    def valid_for_payment?(subscription)
      @errors.clear
      validate_paid_status(subscription)
      validate_active_status(subscription)
      errors.empty?
    end

    # Validates whether the Subscription is in a valid state for cancellation.
    #
    # @param subscription [Billing::Entity::Subscription] The subscription entity to be validated.
    # @return [Boolean] Returns true if the Subscription is valid for cancellation, false otherwise.
    def valid_for_cancellation?(subscription)
      @errors.clear
      validate_paid_status_for_cancellation(subscription)
      errors.empty?
    end

    private

    def validate_paid_status(subscription)
      if subscription.status == 'paid'
        errors << "Subscription is already paid"
      end
    end

    def validate_active_status(subscription)
      if subscription.status == 'canceled'
        errors << "Cannot pay for a canceled subscription"
      end
    end

    def validate_paid_status_for_cancellation(subscription)
      if subscription.status != 'paid'
        errors << "Only paid subscriptions can be canceled"
      end
    end
  end
end
