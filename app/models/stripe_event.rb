# The StripeEvent model is responsible for storing all webhook events received from Stripe.
# Each event is saved with its unique event ID, type, payload, and a status indicating
# whether it has been processed, unhandled, or failed.
#
# Attributes:
#   - event_id: [String] The unique identifier for the Stripe event.
#   - event_type: [String] The type of the event, such as 'payment_intent.succeeded'.
#   - payload: [JSONB] The full JSON payload of the event as received from Stripe.
#   - status: [String] The status of the event (e.g., 'pending', 'processed', 'unhandled', 'failed').
#   - processed_at: [Datetime] The timestamp when the event was processed, if applicable.
#
# Validations:
#   - Ensures presence of event_id, event_type, payload, and status.
#   - Ensures uniqueness of event_id to avoid duplicate processing.
#   - Validates that status is one of the allowed values.
class StripeEvent < ApplicationRecord
  # Validations
  validates :event_id, :event_type, :payload, :status, presence: true
  validates :event_id, uniqueness: true
  validates :status, inclusion: { in: %w[pending processed unhandled failed], message: "%{value} is not a valid status" }
  validates :attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scope for filtering by status
  scope :pending, -> { where(status: 'pending') }
  scope :processed, -> { where(status: 'processed') }
  scope :unhandled, -> { where(status: 'unhandled') }
  scope :failed, -> { where(status: 'failed') }
end
