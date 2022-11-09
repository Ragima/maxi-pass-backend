# frozen_string_literal: true
module Contents
  module Helpers
    module ConstructorHelper
      def grouped_vault_items
        @grouped_vault_items = {}
        return [] if @vault_items.empty? || @vault_items.nil?

        @vault_items.each do |vault_item|
          web_address = vault_item.decrypted_content['web_address']
          unless web_address.blank?
            if @grouped_vault_items.keys.include?(web_address)
              @grouped_vault_items[web_address]['passwords']
                  .push(id: vault_item.id, username: vault_item.decrypted_content['username'])
            else
              @grouped_vault_items[web_address] = {
                  'page_login' => vault_item.decrypted_content['login_page'],
                  'passwords' => [id: vault_item.id, username: vault_item.decrypted_content['username']]
              }
            end
          end
        end
        @grouped_vault_items
      end
    end
  end
end
