class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: { on_delete: :cascade }
      t.references :subscription_action, foreign_key: { on_delete: :cascade }
    end
  end
end
