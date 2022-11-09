# frozen_string_literal: true

module Users
  module Concerns
    module User
      extend ActiveSupport::Concern

      include ComplicatedKeyGenerator
      include Cipher

      def generate_master_key
        self.master_key ||= Base64.encode64(complicated_key)
      end

      def generate_session_key
        Base64.encode64(encrypt_key(complicated_key, temp_phrase))
      end

      def decrypt_session_key(complicated_key, session_key)
        self.temp_phrase = decrypt_key(Base64.decode64(complicated_key), Base64.decode64(session_key))
      end
    end
  end
end
