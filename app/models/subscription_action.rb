class SubscriptionAction < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  validates :entity_type, uniqueness: { scope: :action_type }

  def self.find_by_subscription_action_id(id)
    find_by(id: id)
  end
end
