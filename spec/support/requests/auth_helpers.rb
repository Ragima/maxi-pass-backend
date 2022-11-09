# frozen_string_literal: true

module Requests
  module AuthHelpers
    module Extensions
      def sign_in(user)
        let(:auth_helpers_auth_token) do
          combined_auth_headers(self.public_send(user))
        end
      end
    end

    module Includables
      HTTP_HELPERS_TO_OVERRIDE =
        %i[get post patch put delete].freeze

      HTTP_HELPERS_TO_OVERRIDE.each do |helper|
        define_method(helper) do |path, **args|
          add_auth_headers(args)
          args == {} ? super(path) : super(path, **args)
        end
      end

      private

      def add_auth_headers(args)
        return unless defined? auth_helpers_auth_token

        args[:headers] ||= {}
        args[:headers].merge!(auth_helpers_auth_token)
      end
    end
  end
end
