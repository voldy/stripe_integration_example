Rails.application.config.to_prepare do
  event_publisher = Billing::EventPublisher.instance
  
  # Subscribe to specific events
  event_publisher.subscribe(Billing::Events::SubscriptionCreatedEvent, Listeners::ConsoleLoggerListener)
  event_publisher.subscribe(Billing::Events::PaymentSucceededEvent, Listeners::ConsoleLoggerListener)
  event_publisher.subscribe(Billing::Events::SubscriptionCanceledEvent, Listeners::ConsoleLoggerListener)
end
