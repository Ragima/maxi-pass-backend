class GroupAdminKey < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :key, presence: true
end
