class CreateSubscriptionActions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_actions do |t|
      t.string :entity_type
      t.string :action_type
    end
  end
end
