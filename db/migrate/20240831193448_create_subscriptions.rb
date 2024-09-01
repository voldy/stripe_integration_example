class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions, id: :string do |t|
      t.string :customer_id, null: false
      t.string :status, null: false
      t.datetime :canceled_at

      t.timestamps
    end

    add_index :subscriptions, :customer_id
  end
end
