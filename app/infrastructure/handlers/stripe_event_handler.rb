module Handlers
  # The StripeEventHandler module processes different types of Stripe events.
  # It delegates the actual work to the appropriate use case and returns the result.
  #
  # This module simplifies the processing of Stripe events by routing them to the appropriate use case.
  # It also handles logging for unhandled event types and errors encountered during processing.
  module StripeEventHandler
    # Processes the Stripe event based on its type.
    #
    # This method identifies the type of the Stripe event and delegates the processing to the appropriate use case.
    # It logs and returns :unhandled for unsupported event types and :error for any exceptions raised during processing.
    #
    # @param stripe_event [StripeEvent] The StripeEvent record containing the event data.
    # @return [Symbol] :processed if the event was handled, :unhandled if it was not, and :error if an exception occurred.
    def self.process_event(stripe_event)
      event_type = stripe_event.event_type
      event_data = stripe_event.payload['data']['object']

      result = case event_type
               when 'customer.subscription.created'
                 UseCases::CreateSubscription.new.call(event_data)
               when 'invoice.payment_succeeded'
                 UseCases::MarkSubscriptionAsPaid.new.call(event_data['subscription'])
               when 'customer.subscription.deleted'
                 UseCases::CancelSubscription.new.call(event_data['id'])
               else
                 :unhandled
               end

      handle_result(result, stripe_event)
    rescue StandardError => e
      Rails.logger.error("Error processing event #{stripe_event.event_id}: #{e.message}")
      :error      
    end

    def self.handle_result(result, stripe_event)
      return result if result == :unhandled
      if result.success?
        :processed
      elsif result.failure?
        if stripe_event.attempts + 1 < 5
          stripe_event.increment!(:attempts)
          ProcessStripeEventJob.set(wait: 5.seconds).perform_later(stripe_event.id)
          :rescheduled
        else
          :failed
        end
      end
    end
  end
end
