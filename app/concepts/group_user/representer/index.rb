# frozen_string_literal: true

module GroupUser::Representer
  class Index < Representable::Decorator
    include Representable::Hash::Collection

    self.representation_wrap = :data

    items class: GroupUser do
      property :id
      property :user_id
      property :group_id
      property :role
    end
  end
end