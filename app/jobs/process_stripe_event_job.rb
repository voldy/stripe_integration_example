class ProcessStripeEventJob < ApplicationJob
  queue_as :default

  # Perform the job to process a Stripe event.
  #
  # @param stripe_event_id [Integer] The ID of the StripeEvent record to be processed.
  # @return [void]
  def perform(stripe_event_id)
    stripe_event = StripeEvent.find(stripe_event_id)

    result = Handlers::StripeEventHandler.process_event(stripe_event)
    case result
    when :processed
      stripe_event.update!(status: 'processed', processed_at: Time.current)
    when :unhandled
      stripe_event.update!(status: 'unhandled')
    when :error, :failed
      stripe_event.update!(status: 'failed')
    when :rescheduled
      # Leave the status as 'pending' to indicate it will be retried
      Rails.logger.info("Event #{stripe_event.event_id} rescheduled for later processing")
    end
  end
end
