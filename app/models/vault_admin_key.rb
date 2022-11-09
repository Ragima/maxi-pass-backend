# frozen_string_literal: true

class VaultAdminKey < ApplicationRecord
  belongs_to :vault
  belongs_to :user

  validates :key, presence: true
end
