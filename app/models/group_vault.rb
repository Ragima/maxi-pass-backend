# frozen_string_literal: true

class GroupVault < ApplicationRecord
  belongs_to :group
  belongs_to :vault
end
