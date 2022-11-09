class SubscriptionActionsSerializer
  include FastJsonapi::ObjectSerializer

  attributes :entity_type, :action_type

  has_many :subscriptions
  has_many :users
end
