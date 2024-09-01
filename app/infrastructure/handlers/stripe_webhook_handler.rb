module Handlers::StripeWebhookHandler
  # Processes a Stripe event by storing it in the database and scheduling a job for
  # asynchronous processing. Handles duplicates gracefully by ignoring them.
  #
  # @param event [Stripe::Event] The Stripe event object.
  # @return [StripeEvent] The StripeEvent record created or found during processing.
  def self.process(event)
    stripe_event = StripeEvent.find_or_initialize_by(event_id: event['id'])

    if stripe_event.new_record?
      stripe_event.assign_attributes(
        event_type: event['type'],
        payload: event,
        status: 'pending'
      )
      stripe_event.save!
      ProcessStripeEventJob.perform_later(stripe_event.id)
    end

    stripe_event
  rescue ActiveRecord::RecordInvalid => e
    stripe_event&.update!(status: 'failed')
    raise e
  end
end
