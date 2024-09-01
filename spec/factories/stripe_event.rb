FactoryBot.define do
  factory :stripe_event do
    event_id { "evt_test" }
    event_type { "customer.subscription.created" }
    payload { { "data" => { "object" => {} } } }
    status { "pending" }
    attempts { 0 }
  end
end
