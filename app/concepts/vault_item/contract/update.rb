# frozen_string_literal: true

module VaultItem::Contract
  class Update < VaultItem::Contract::Create
    property :title
    property :tags
    property :only_for_admins

    validates :title, length: 1..50
    validates :tags, length: { maximum: 300 }
  end
end