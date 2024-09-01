class CreateStripeEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :stripe_events do |t|
      t.string :event_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false
      t.string :status, null: false, default: 'pending'
      t.datetime :processed_at
      t.integer :attempts, null: false, default: 0 # Add this line
      t.timestamps
    end

    add_index :stripe_events, :event_id, unique: true
  end
end
