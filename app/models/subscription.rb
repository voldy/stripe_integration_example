# The Subscription model represents a subscription entity within the system.
# It includes validations to ensure that essential attributes are present and valid.
#
# Attributes:
# - id: [String] The unique identifier for the subscription (generated by Stripe).
# - customer_id: [String] The unique identifier for the customer associated with this subscription.
# - status: [String] The current status of the subscription, which must be one of the following: 'unpaid', 'paid', or 'canceled'.
#
# Validations:
# - customer_id: Must be present to associate the subscription with a customer.
# - status: Must be present and must be either 'unpaid', 'paid', or 'canceled'.
#
# Example usage:
#   subscription = Subscription.new(customer_id: 'cus_123', status: 'unpaid')
#   subscription.save if subscription.valid?
#
class Subscription < ApplicationRecord
  validates :customer_id, presence: true
  validates :status, presence: true
  validates :status, inclusion: { in: %w[unpaid paid canceled], message: "%{value} is not a valid status" }
end
