class AddSubsriptionActions < ActiveRecord::Migration[5.2]
  def change
    actions = { Document: %w[Create Read Update Delete] }
    actions_to_create = []
    actions.each do |key, value|
      value.each do |element|
        actions_to_create.push(entity_type: key, action_type: element)
      end
    end
    SubscriptionAction.import(actions_to_create)
  end
end
