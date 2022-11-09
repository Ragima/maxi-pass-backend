# frozen_string_literal: true

module VaultItemsHelper
  def create_vault_item(entity_sym, user, vault, closed_content)
    item = create entity_sym, vault: vault
    encoder = Encoder.new(user)
    encrypted_content = encoder.update_encrypted_content(closed_content, vault)
    item.update_attributes(content: encrypted_content)
    item
  end

end