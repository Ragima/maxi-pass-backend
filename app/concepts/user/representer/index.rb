# frozen_string_literal: true

module User::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: User do
      property :id
      property :email
      property :first_name
      property :last_name
      property :name
      property :team_name
      property :role_id
      property :reset_pass
      property :blocked
      property :extension_access
      property :lead, exec_context: :decorator

      def lead
        GroupUser.exists?(user: represented, role: 'lead')
      end
    end
  end
end
