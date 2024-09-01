# app/domains/billing/entities/subscription.rb

module Billing::Entities
  # The Subscription class represents a subscription in the billing domain.
  # It manages the state and behavior related to a subscription's lifecycle.
  # Validation logic is decoupled from this class and can be injected when needed.
  #
  class Subscription
    attr_reader :id, :status, :customer_id

    # Initializes a new Subscription instance.
    #
    # @param id [String] The unique identifier for the subscription.
    # @param customer_id [String] The unique identifier for the customer associated with the subscription.
    # @param status [String] The initial status of the subscription (default: 'unpaid').
    # @param validator [Object] The validator responsible for validating the subscription.
    def initialize(id:, customer_id:, status: 'unpaid', validator: nil)
      @id = id
      @customer_id = customer_id
      @status = status
      @validator = validator || Billing::Validators::SubscriptionValidator.new
    end

    # Marks the subscription as paid if it is in a valid state.
    #
    # @return [Result] Returns a Result object indicating success or failure.
    def mark_as_paid()
      if @validator.valid_for_payment?(self)
        @status = 'paid'
        Result.success(self)
      else
        Result.failure(@validator.errors.join(", "))
      end
    end

    # Cancels the subscription if it is in a valid state.
    #
    # @return [Result] Returns a Result object indicating success or failure.
    def cancel
      if @validator.valid_for_cancellation?(self)
        @status = 'canceled'
        Result.success(self)
      else
        Result.failure(@validator.errors.join(", "))
      end
    end
  end
end
