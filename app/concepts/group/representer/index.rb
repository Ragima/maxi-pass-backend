# frozen_string_literal: true

module Group::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: Group do
      property :id
      property :name
      property :parent_group_id
      property :created_at
      property :updated_at
      property :users, exec_context: :decorator
      property :vaults, exec_context: :decorator

      def users
        represented.users.where.not(role_id: 'admin').size
      end

      def vaults
        represented.vaults.size
      end
    end
  end
end