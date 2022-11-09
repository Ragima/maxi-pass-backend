# frozen_string_literal: true

module Users
  module Concerns
    module ResourceFinder
      extend ActiveSupport::Concern

      def get_case_insensitive_field_from_resource_params(fields)
        q_values = {}

        fields.each do |field|
          q_value = resource_params[field.to_sym]

          q_value.downcase! if resource_class.case_insensitive_keys.include?(field.to_sym)

          q_value.strip! if resource_class.strip_whitespace_keys.include?(field.to_sym)
          q_values[field.to_sym] = q_value
        end

        q_values
      end

      def find_resource(q_values)
        q = ''
        q_values.keys.each do |q_value|
          q += "#{q_value} = ? AND "
        end
        # fix for mysql default case insensitivity
        q += "true"
        q = 'BINARY ' + q if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'

        @resource = resource_class.where(q, *q_values.values).first
      end
    end
  end
end
