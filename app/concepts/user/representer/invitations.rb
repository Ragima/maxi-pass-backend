# frozen_string_literal: true

module User::Representer
  class Invitations < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: User do
      property :id
      property :email
      property :first_name
      property :last_name
      property :name
      property :team_name
      property :invited_by_name
      property :accept_to
      property :blocked
      property :extension_access
    end
  end
end
