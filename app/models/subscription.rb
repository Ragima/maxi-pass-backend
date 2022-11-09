class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_action
end
