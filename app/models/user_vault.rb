# frozen_string_literal: true

class UserVault < ApplicationRecord
  belongs_to :user
  belongs_to :vault
end
