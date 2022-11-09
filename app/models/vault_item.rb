# frozen_string_literal: true

class VaultItem < ApplicationRecord
  attr_accessor :decrypted_content

  belongs_to :vault
  has_many :documents, dependent: :destroy
end
