# frozen_string_literal: true

module GroupUser::Representer
  class Show < Representable::Decorator
    include Representable::Hash

    nested :data do
      property :id
      property :group_id
      property :user_id
      property :role
    end
  end
end